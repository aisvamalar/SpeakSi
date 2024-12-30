from flask import Flask, request, jsonify
import torch
from openvoice import OpenVoiceModel  # Ensure OpenVoiceModel API is correct
import io
import librosa
import numpy as np
import soundfile as sf

app = Flask(__name__)

# Load the OpenVoice model
model_path='checkpoints\converter\checkpoint.pth'
model = OpenVoiceModel.from_pretrained(model_path)

@app.route('/clone-voice', methods=['POST'])
def clone_voice():
    try:
        audio_file = request.files.get('audio')
        if not audio_file:
            return jsonify({'error': 'No audio file provided'}), 400

        # Load audio using librosa
        audio_data, samplerate = librosa.load(io.BytesIO(audio_file.read()), sr=None)
        audio_tensor = torch.tensor(audio_data).unsqueeze(0)  # Add batch dimension

        # Clone voice using model
        cloned_voice = model.clone_voice(audio_tensor)

        # Save the cloned voice to a file
        cloned_voice_path = 'cloned_voice.wav'
        sf.write(cloned_voice_path, cloned_voice.squeeze().numpy(), samplerate)

        return jsonify({'message': 'Voice cloned successfully', 'cloned_voice_path': cloned_voice_path})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/text-to-speech', methods=['POST'])
def text_to_speech():
    try:
        text = request.json.get('text')
        if not text:
            return jsonify({'error': 'No text provided'}), 400

        # Implement your TTS functionality here
        # Example placeholder for generating speech from text
        speech = generate_speech(text)  # Ensure this function is defined

        # Save generated speech to a file
        audio_path = 'generated_speech.wav'
        samplerate = 22050  # Ensure you have the correct sample rate
        sf.write(audio_path, speech.squeeze().numpy(), samplerate)

        return jsonify({'message': 'Text converted to speech successfully', 'audio_path': audio_path})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
