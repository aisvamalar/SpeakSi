import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speaksi/screens/recording_data.dart';
import 'package:speech_to_text/speech_to_text.dart';

class RecordingService {
  final Record _audioRecorder = Record();
  final SpeechToText _speechToText = SpeechToText();
  String _currentText = '';

  Future<void> initialize() async {
    await _speechToText.initialize();
  }

  Future<String> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        path: filePath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );

      _speechToText.listen(
        onResult: (result) {
          _currentText = result.recognizedWords;
        },
      );

      return filePath;
    }
    throw Exception('Microphone permission not granted');
  }

  Future<RecordingData> stopRecording(String path) async {
    await _speechToText.stop();
    await _audioRecorder.stop();

    return RecordingData(
      path: path,
      text: _currentText,
      timestamp: DateTime.now(),
    );
  }

  Future<void> deleteRecording(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}