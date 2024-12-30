import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';

void main() => runApp(const RecordingApp());

class RecordingApp extends StatelessWidget {
  const RecordingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const RecordingScreen(),
    );
  }
}

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final record = Record();
  final audioPlayer = AudioPlayer();
  final flutterSoundRecorder = FlutterSoundRecorder();

  bool isRecording = false;
  String? currentRecordingPath;
  List<String> recordings = [];
  List<double> waveformData = [];
  Timer? waveformTimer;
  Duration recordingDuration = Duration.zero;
  Timer? durationTimer;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _loadRecordings();
  }

  Future<void> _initializeRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await flutterSoundRecorder.openRecorder();
  }

  Future<void> _loadRecordings() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync()
        .where((file) => file.path.endsWith('.aac'))
        .map((file) => file.path)
        .toList();
    setState(() {
      recordings = files;
    });
  }

  void _startRecording() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      currentRecordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

      await record.start(path: currentRecordingPath);

      setState(() {
        isRecording = true;
        waveformData.clear();
      });

      // Start generating waveform data
      waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          waveformData.add(Random().nextDouble()); // Simulate audio levels
          if (waveformData.length > 30) waveformData.removeAt(0);
        });
      });

      // Start recording duration timer
      durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          recordingDuration += const Duration(seconds: 1);
        });
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  void _stopRecording() async {
    try {
      await record.stop();
      waveformTimer?.cancel();
      durationTimer?.cancel();

      setState(() {
        isRecording = false;
        recordingDuration = Duration.zero;
      });

      if (currentRecordingPath != null) {
        setState(() {
          recordings.add(currentRecordingPath!);
        });
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _playRecording(String path) async {
    try {
      await audioPlayer.play(DeviceFileSource(path));
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  Future<void> _shareRecording(String path) async {
    try {
      await Share.shareFiles([path]);
    } catch (e) {
      print('Error sharing recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTopSection(),
          const SizedBox(height: 20),
          _buildTextSection(),
          const SizedBox(height: 30),
          _buildWaveformSection(),
          _buildRecordingList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isRecording ? _stopRecording : _startRecording,
        backgroundColor: Colors.purple,
        child: Icon(isRecording ? Icons.stop : Icons.mic),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTopSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade900, Colors.purple],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.purple.shade700, Colors.purple.shade900],
                  ),
                ),
              ),
              Icon(
                isRecording ? Icons.stop : Icons.mic,
                size: 60,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isRecording)
            Text(
              '${recordingDuration.inMinutes}:${(recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildWaveformSection() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: waveformData.map((value) {
          return Container(
            width: 5,
            height: value * 80,
            decoration: BoxDecoration(
              color: Colors.purple.shade300,
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Siddhu's recordings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Chill your mind",
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: recordings.length,
        itemBuilder: (context, index) {
          final path = recordings[index];
          final fileName = path.split('/').last;
          return ListTile(
            leading: const Icon(Icons.mic, color: Colors.purple),
            title: Text(
              fileName,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: () => _playRecording(path),
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => _shareRecording(path),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    record.dispose();
    audioPlayer.dispose();
    flutterSoundRecorder.closeRecorder();
    waveformTimer?.cancel();
    durationTimer?.cancel();
    super.dispose();
  }
}