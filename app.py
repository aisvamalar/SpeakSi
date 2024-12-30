from flask import Flask, request, jsonify
import numpy as np
import librosa
from transformers import WhisperProcessor, WhisperForConditionalGeneration
import os
import pandas as pd
from pydub import AudioSegment
import io
import soundfile as sf
import subprocess
import uuid
import torch
from google.cloud import texttospeech
from scipy.spatial.distance import euclidean
app = Flask(__name__)

# Load your trained model
model = WhisperForConditionalGeneration.from_pretrained('./check_point')
processor = WhisperProcessor.from_pretrained('./check_point')



@app.route('/predict', methods=['POST'])
def predict():

    if 'file' not in request.files:
        return jsonify({'error': 'No file part'})
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'})
    
    file_path = os.path.join('./', file.filename)
    file.save(file_path)
    time_based_uuid = uuid.uuid1()
    subprocess.run(['ffmpeg', '-i', file_path, '-acodec', 'pcm_s16le', '-ar', '44100', f'{time_based_uuid}.wav'])
    filename = f"{time_based_uuid}.wav"
    audio_array, sampling_rate = librosa.load(filename, sr=16000)
    input_features = processor.feature_extractor(audio_array, sampling_rate=sampling_rate, return_tensors="pt").input_features

    with torch.no_grad():
            predicted_ids = model.generate(input_features)

    transcription = processor.tokenizer.batch_decode(predicted_ids, skip_special_tokens=True)
    os.remove(file_path)  # Clean up the saved file

    print("the word spoken:", transcription[0])
    return jsonify({'class': transcription[0]})
    
@app.route('/check-pronunciation', methods=['POST'])
def check_pronunciation():
    # Set up Google Cloud credentials
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "API_KEY.json"

    # Path for saving generated and uploaded files
    DRIVE_PATH = 'audio'
    os.makedirs(DRIVE_PATH, exist_ok=True)

    # Extract features from audio file
    def feature_extractor(file_name):
        try:
            audio, sample_rate = librosa.load(file_name, res_type='kaiser_fast')
            mfccs_features = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=40)
            mfccs_scaled_features = np.mean(mfccs_features.T, axis=0)
            chroma_features = librosa.feature.chroma_stft(y=audio, sr=sample_rate)
            chroma_scaled_features = np.mean(chroma_features.T, axis=0)
            spectral_contrast = librosa.feature.spectral_contrast(y=audio, sr=sample_rate)
            spectral_contrast_scaled = np.mean(spectral_contrast.T, axis=0)
            zero_crossing_rate = librosa.feature.zero_crossing_rate(y=audio)
            zero_crossing_rate_scaled = np.mean(zero_crossing_rate.T, axis=0)
            features = np.hstack((mfccs_scaled_features, chroma_scaled_features, 
                                spectral_contrast_scaled, zero_crossing_rate_scaled))
            return features
        except Exception as e:
            raise RuntimeError(f"Error extracting features: {str(e)}")

    if 'audio' not in request.files or 'text' not in request.form:
        return jsonify({"error": "Missing audio file or text"}), 400

    try:
        # Generate unique IDs for file names
        session_id = str(uuid.uuid4())
        uploaded_file = request.files['audio']
        input_text = request.form['text']

        # Save paths
        uploaded_file_path = os.path.join(DRIVE_PATH, f"upload_{session_id}.wav")
        generated_audio_path = os.path.join(DRIVE_PATH, f"generated_{session_id}.wav")
        converted_upload_path = os.path.join(DRIVE_PATH, f"converted_upload_{session_id}.wav")
        converted_generated_path = os.path.join(DRIVE_PATH, f"converted_generated_{session_id}.wav")

        # Save uploaded file
        uploaded_file.save(uploaded_file_path)

        # Generate audio from text
        client = texttospeech.TextToSpeechClient()
        synthesis_input = texttospeech.SynthesisInput(text=input_text)
        voice = texttospeech.VoiceSelectionParams(
            language_code="en-US",
            ssml_gender=texttospeech.SsmlVoiceGender.MALE
        )
        audio_config = texttospeech.AudioConfig(
            audio_encoding=texttospeech.AudioEncoding.LINEAR16
        )
        response = client.synthesize_speech(
            input=synthesis_input,
            voice=voice,
            audio_config=audio_config
        )

        # Save generated audio
        with open(generated_audio_path, "wb") as out:
            out.write(response.audio_content)

        # Convert both audio files for comparison
        subprocess.run([
            'ffmpeg', '-y', '-i', uploaded_file_path,
            '-acodec', 'pcm_s16le', '-ar', '44100',
            converted_upload_path
        ], check=True)

        subprocess.run([
            'ffmpeg', '-y', '-i', generated_audio_path,
            '-acodec', 'pcm_s16le', '-ar', '44100',
            converted_generated_path
        ], check=True)

        # Extract features and calculate similarity
        user_features = feature_extractor(converted_upload_path)
        generated_features = feature_extractor(converted_generated_path)
        similarity_score = euclidean(user_features, generated_features)/2
        accuracy = 100 - (similarity_score / 1000) * 100 if similarity_score < 1000 else 0

        # Clean up temporary files
        for file_path in [uploaded_file_path, generated_audio_path, 
                         converted_upload_path, converted_generated_path]:
            if os.path.exists(file_path):
                os.remove(file_path)

        return jsonify({
            "similarity_score": float(similarity_score),
            "accuracy": f"{accuracy:.2f}%"
        })

    except Exception as e:
        # Clean up any remaining temporary files
        for file_path in [
            uploaded_file_path, generated_audio_path,
            converted_upload_path, converted_generated_path
        ]:
            if os.path.exists(file_path):
                os.remove(file_path)
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000,debug=True)
