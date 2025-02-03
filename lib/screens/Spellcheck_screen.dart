import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PronunciationScreen extends StatefulWidget {
  final int level;
  final Function(int) onLevelComplete;
  final Function() onWordCompleted;

  const PronunciationScreen({
    Key? key,
    required this.level,
    required this.onLevelComplete,
    required this.onWordCompleted,
  }) : super(key: key);

  @override
  _PronunciationScreenState createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  final Record _recorder = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isLoading = false;
  String? _audioPath;
  String _generatedWord = '';
  String _similarityScore = '';
  List<String> _mismatchedLetters = [];
  List<String> _correctLetters = [];
  String _pronunciationTips = '';
  bool _showTrophyAnimation = false;

  final Map<int, List<String>> levelWords = {
    1: ['Cat', 'Dog', 'Hat', 'Bat'],
    2: ['Apple', 'Table', 'Chair', 'Book'],
    3: ['Mountain', 'Rainbow', 'Sunshine', 'Butterfly'],
    4: ['Education', 'Beautiful', 'Wonderful', 'Adventure'],
    5: ['Extraordinary', 'Imagination', 'Sophisticated', 'Achievement'],
  };

  @override
  void initState() {
    super.initState();
    _generateRandomWord();
  }

  @override
  void dispose() async {
    _audioPlayer.dispose();
    await _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (hasPermission) {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/recording.m4a';
      setState(() {
        _audioPath = tempPath;
      });

      await _recorder.start(
        path: tempPath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _playRecording() async {
    if (_audioPath != null) {
      await _audioPlayer.setFilePath(_audioPath!);
      _audioPlayer.play();
    }
  }

  Future<void> _sendToAPI() async {
    if (_audioPath == null || _generatedWord.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    var uri = Uri.parse('http://192.168.232.242:5000/check-pronunciation');
    var request = http.MultipartRequest('POST', uri)
      ..fields['text'] = _generatedWord
      ..files.add(await http.MultipartFile.fromPath('audio', _audioPath!));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var data = json.decode(responseData.body);
        setState(() {
          _similarityScore = data['similarity'].toString();
          _mismatchedLetters = List<String>.from(data['mis_matchings'] ?? []);
          _correctLetters = _generatedWord.split('')
              .where((letter) => !_mismatchedLetters.contains(letter))
              .toList();
          _pronunciationTips = data['tips'] ?? 'No specific tips available.';
        });

        // Check if pronunciation is good enough to proceed
        if (double.parse(_similarityScore) > 70) {
          Future.delayed(const Duration(seconds: 100), () {
            if (mounted) {
              setState(() {
                _showTrophyAnimation = true;
              });
              widget.onWordCompleted();
            }
          });
        }
      } else {
        setState(() {
          _similarityScore = 'Error';
          _mismatchedLetters = [];
          _correctLetters = [];
          _pronunciationTips = 'Error checking pronunciation';
        });
      }
    } catch (e) {
      setState(() {
        _similarityScore = 'Error';
        _mismatchedLetters = [];
        _correctLetters = [];
        _pronunciationTips = 'Network error: Unable to check pronunciation';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateRandomWord() {
    final words = levelWords[widget.level] ?? levelWords[1]!;
    setState(() {
      _generatedWord = words[DateTime.now().millisecondsSinceEpoch % words.length];
      _similarityScore = '';
      _mismatchedLetters = [];
      _correctLetters = [];
      _pronunciationTips = '';
      _showTrophyAnimation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4527A0).withOpacity(0.5),
        elevation: 0,
        title: const Text('Pronunciation Checker'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Pronounce this word:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _generatedWord,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording ? Colors.red : const Color(0xFF5B3BBB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: _isRecording ? _stopRecording : _startRecording,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isRecording ? 'Stop Recording' : 'Start Recording',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_audioPath != null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B3BBB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: _playRecording,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.play_arrow, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Play Recording',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B3BBB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    ),
                    onPressed: _audioPath != null && !_isLoading ? _sendToAPI : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Check Pronunciation',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_similarityScore.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Similarity Score: $_similarityScore%',
                          style: TextStyle(
                            color: double.parse(_similarityScore) > 70
                                ? Colors.green
                                : Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _generatedWord.length,
                                (index) {
                              final letter = _generatedWord[index];
                              final color = _mismatchedLetters.contains(letter)
                                  ? const Color(0xFFE34646)
                                  : const Color(0xFF4CAF50);

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: Container(
                                  width: 30,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      letter.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4527A0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.lightbulb,
                                    color: Color(0xFFFFC107),
                                    size: 28,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Pronunciation Tips:',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _pronunciationTips,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_showTrophyAnimation)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 60,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurpleAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}