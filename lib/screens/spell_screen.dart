import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';

class SpellScreen extends StatefulWidget {
  const SpellScreen({super.key});

  @override
  State<SpellScreen> createState() => _SpellScreenState();
}

class _SpellScreenState extends State<SpellScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _audioPlayer = AudioPlayer();
  final _audioRecorder = Record();

  String? _recordedPath;
  String? _generatedAudioPath;
  String? _imageUrl;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isLoadingImage = false;
  String _result = '';

  // Enhanced color palette
  static const primaryColor = Color(0xFF6C63FF);
  static const secondaryColor = Color(0xFF8B80FF);
  static const backgroundColor = Color(0xFF0A0A1E);
  static const surfaceColor = Color(0xFF1A1A2F);
  static const accentColor = Color(0xFFFF63B8);
  static const successColor = Color(0xFF4CAF50);

  // Animation controllers
  late AnimationController _recordingAnimationController;
  late AnimationController _buttonScaleController;
  late AnimationController _resultSlideController;

  // Animations
  late Animation<double> _recordingAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<Offset> _resultSlideAnimation;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _setupAnimations();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _fetchImage(String word) async {
    setState(() => _isLoadingImage = true);

    try {
      // Replace YOUR_UNSPLASH_ACCESS_KEY with your actual Unsplash access key
      final response = await http.get(
        Uri.parse(
            'https://api.unsplash.com/search/photos?query=$word&per_page=1'
        ),
        headers: {
          'Authorization': 'Client-ID YOUR_UNSPLASH_ACCESS_KEY',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          setState(() {
            _imageUrl = data['results'][0]['urls']['regular'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching image: $e');
    } finally {
      setState(() => _isLoadingImage = false);
    }
  }

  void _setupAnimations() {
    // Recording pulse animation
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _recordingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _recordingAnimationController,
      curve: Curves.easeInOut,
    ));

    // Button scale animation
    _buttonScaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonScaleController,
      curve: Curves.easeInOut,
    ));

    // Result slide animation
    _resultSlideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _resultSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultSlideController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _startRecording() async {
    try {
      final dir = await getTemporaryDirectory();
      final filepath = path.join(dir.path, 'recorded_audio.wav');
      _recordedPath = filepath;

      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          encoder: AudioEncoder.wav,
          samplingRate: 44100,
          path: filepath,
        );
        setState(() => _isRecording = true);
      } else {
        _showSnackBar('Microphone permission denied');
      }
    } catch (e) {
      debugPrint('Error recording: $e');
      _showSnackBar('Error recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() => _isRecording = false);
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _showSnackBar('Error stopping recording: $e');
    }
  }

  Future<void> _playAudio(String? audioPath) async {
    if (audioPath == null) return;

    try {
      await _audioPlayer.setFilePath(audioPath);
      await _audioPlayer.play();
      setState(() => _isPlaying = true);

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() => _isPlaying = false);
        }
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _showSnackBar('Error playing audio: $e');
    }
  }

  Future<void> _compareAudio() async {
    if (_recordedPath == null || _textController.text.isEmpty) {
      _showSnackBar('Please record audio and enter text first');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Fetch image for the word
      await _fetchImage(_textController.text);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.142.242:5000/check-pronunciation'),
      );

      request.fields['text'] = _textController.text;
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        _recordedPath!,
      ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        setState(() {
          _result =
          'Similarity Score: ${jsonResponse['similarity_score'].toStringAsFixed(2)}';
          _generatedAudioPath = jsonResponse['generated_audio_path'];
        });
        _resultSlideController.forward();
      } else {
        setState(() => _result = 'Error: ${jsonResponse['error']}');
      }
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: surfaceColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicContainer({
    required Widget child,
    double blur = 10,
    double opacity = 0.1,
    bool addGlow = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: addGlow
            ? [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: -5,
          )
        ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    bool isLoading = false,
    bool isPrimary = true,
  }) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: _buildGlassmorphicContainer(
        blur: 15,
        opacity: 0.15,
        addGlow: isPrimary,
        child: Container(
          width: double.infinity,
          height: 60,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTapDown: (_) => _buttonScaleController.forward(),
              onTapUp: (_) => _buttonScaleController.reverse(),
              onTapCancel: () => _buttonScaleController.reverse(),
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isPrimary ? accentColor : secondaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isPrimary
                            ? Colors.white
                            : Colors.white.withOpacity(0.9),
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: accentColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    if (!_isRecording) return const SizedBox.shrink();

    return Row(
      children: [
        ScaleTransition(
          scale: _recordingAnimation,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Recording...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    if (_result.isEmpty) return const SizedBox.shrink();

    final score = double.tryParse(
      _result.split(': ').last.replaceAll(RegExp(r'[^0-9.]'), ''),
    ) ??
        0.0;

    return SlideTransition(
      position: _resultSlideAnimation,
      child: _buildGlassmorphicContainer(
        blur: 15,
        opacity: 0.15,
        addGlow: score > 0.7,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    score > 0.7 ? Icons.emoji_events : Icons.analytics,
                    color: score > 0.7 ? Colors.amber : accentColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    score > 0.7 ? 'Excellent!' : 'Pronunciation Score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _result,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: score > 0.7 ? successColor : Colors.white.withOpacity(0.9),
                ),
              ),
              if (score > 0.7) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: successColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: successColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: successColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Perfect Pronunciation!',
                        style: TextStyle(
                          color: successColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildImagePreview() {
    if (_imageUrl == null && !_isLoadingImage) return const SizedBox.shrink();

    return _buildGlassmorphicContainer(
      blur: 15,
      opacity: 0.15,
      child: Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: _isLoadingImage
            ? Shimmer.fromColors(
          baseColor: surfaceColor,
          highlightColor: surfaceColor.withOpacity(0.5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CachedNetworkImage(
            imageUrl: _imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: surfaceColor,
              highlightColor: surfaceColor.withOpacity(0.5),
              child: Container(
                color: Colors.white,
              ),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SpeakEasy',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              _buildGlassmorphicContainer(
                blur: 15,
                opacity: 0.15,
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter word to practice...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildImagePreview(),
              const SizedBox(height: 24),
              _buildRecordingIndicator(),
              const SizedBox(height: 16),
              _buildActionButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                text: _isRecording ? 'Stop Recording' : 'Start Recording',
                icon: _isRecording ? Icons.stop : Icons.mic,
                isPrimary: true,
              ),
              if (_recordedPath != null) ...[
                _buildActionButton(
                  onPressed: () => _playAudio(_recordedPath),
                  text: 'Play Recording',
                  icon: Icons.play_arrow,
                  isPrimary: false,
                ),
              ],
              if (_generatedAudioPath != null) ...[
                _buildActionButton(
                  onPressed: () => _playAudio(_generatedAudioPath),
                  text: 'Play Generated Audio',
                  icon: Icons.volume_up,
                  isPrimary: false,
                ),
              ],
              _buildActionButton(
                onPressed: _compareAudio,
                text: 'Check Pronunciation',
                icon: Icons.compare,
                isLoading: _isLoading,
                isPrimary: true,
              ),
              const SizedBox(height: 24),
              _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    _recordingAnimationController.dispose();
    _buttonScaleController.dispose();
    _resultSlideController.dispose();
    super.dispose();
  }
}