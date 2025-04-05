import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

class CombinedScreen extends StatefulWidget {
  const CombinedScreen({Key? key}) : super(key: key);

  @override
  State<CombinedScreen> createState() => _CombinedScreenState();
}

class _CombinedScreenState extends State<CombinedScreen> with SingleTickerProviderStateMixin {
  final Record _audioRecorder = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isRecording = false;
  String? recordingPath;
  String? predictionResult;
  bool isProcessing = false;
  bool isPlaying = false;
  late AnimationController _animationController;

  // Define theme colors
  static const primaryPurple = Color(0xFF6C3CE9);
  static const darkPurple = Color(0xFF2A0F6F);
  static const lightPurple = Color(0xFF8B6CEF);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (!await _audioRecorder.hasPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required to record audio'),
          ),
        );
      }
    }
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final String filePath = p.join(
        appDocumentsDir.path,
        "recording_${DateTime.now().millisecondsSinceEpoch}.wav",
      );

      try {
        await _audioRecorder.start(
          path: filePath,
          encoder: AudioEncoder.wav,
          samplingRate: 16000,
        );
        if (mounted) {
          setState(() {
            isRecording = true;
            recordingPath = filePath;
            predictionResult = null;
          });
        }
      } catch (e) {
        print('Error starting recording: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to start recording')),
          );
        }
      }
    }
  }

  Future<void> stopRecording() async {
    try {
      final filePath = await _audioRecorder.stop();
      if (filePath != null && mounted) {
        setState(() {
          isRecording = false;
          isProcessing = true;
          recordingPath = filePath;
        });
        await uploadAudio(filePath);
      }
    } catch (e) {
      print('Error stopping recording: $e');
      if (mounted) {
        setState(() {
          isRecording = false;
          isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to stop recording')),
        );
      }
    }
  }

  Future<void> pronouncePrediction(String text) async {
    if (isPlaying) {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
      return;
    }

    const String apiKey = "AIzaSyCWLyaSV-AeZfKijTI2agIufCdbbS-j4S8"; // Replace with your actual API key
    const String apiUrl = "https://texttospeech.googleapis.com/v1/text:synthesize";

    final Map<String, dynamic> requestBody = {
      'input': {'text': text},
      'voice': {
        'languageCode': 'en-US',
        'name': 'en-US-Wavenet-D',
      },
      'audioConfig': {'audioEncoding': 'MP3'},
    };

    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String audioContent = responseData['audioContent'];

        final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
        final String filePath = p.join(appDocumentsDir.path, "tts_output.mp3");
        final File audioFile = File(filePath);
        await audioFile.writeAsBytes(base64.decode(audioContent));

        await _audioPlayer.play(DeviceFileSource(filePath));
        if (mounted) {
          setState(() {
            isPlaying = true;
          });
        }

        _audioPlayer.onPlayerComplete.listen((event) {
          if (mounted) {
            setState(() {
              isPlaying = false;
            });
          }
        });
      } else {
        throw Exception('Failed to get TTS audio: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during TTS: $e');
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to play audio')),
        );
      }
    }
  }

  Future<void> uploadAudio(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.201.242:5000/predict'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        if (mounted) {
          setState(() {
            predictionResult = jsonResponse['class'];
            isProcessing = false;
          });
        }
      } else {
        throw Exception('Failed to upload audio file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during upload: $e');
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process audio')),
        );
      }
    }
  }

  Widget _buildWaveformAnimation() {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          20,
              (index) => AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final double wave = (index % 2 == 0 ? 1 : -1) *
                  (_animationController.value + index / 20);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 3,
                height: 30 + 20 * wave.abs(),
                decoration: BoxDecoration(
                  color: lightPurple.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            primaryPurple.withOpacity(0.7),
            primaryPurple,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 15,
          ),
        ],
      ),
      child: Icon(
        isRecording ? Icons.stop : Icons.mic,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Widget _buildPredictionCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryPurple.withOpacity(0.8),
            darkPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Your words",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            predictionResult ?? "",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              if (predictionResult != null) {
                pronouncePrediction(predictionResult!);
              }
            },
            icon: Icon(
              isPlaying ? Icons.stop : Icons.volume_up,
              color: primaryPurple,
            ),
            label: Text(
              isPlaying ? "Stop" : "Listen",
              style: TextStyle(color: primaryPurple),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Tap & Speak",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              darkPurple.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: isProcessing
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: primaryPurple,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Processing...",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                        : predictionResult != null
                        ? _buildPredictionCard()
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isRecording) _buildWaveformAnimation(),
                        const SizedBox(height: 40),
                        Text(
                          isRecording ? "We are listening" : "Let's start!",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: GestureDetector(
                  onTapDown: (_) async {
                    if (isRecording) {
                      _animationController.stop();
                      await stopRecording();
                    } else {
                      _animationController.repeat();
                      await startRecording();
                    }
                  },
                  child: _buildMicButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}