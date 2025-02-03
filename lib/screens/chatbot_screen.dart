import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speaksi/screens/spell_screen.dart';
import 'package:speaksi/screens/voiceassistant_screen.dart';

class ChatService {
  final String baseUrl;
  final http.Client client;

  ChatService({
    this.baseUrl = 'http://192.168.169.136:5000',
    http.Client? client,
  }) : this.client = client ?? http.Client();

  Future<Map<String, dynamic>> sendQuery(String message) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class ModernChatScreen extends StatefulWidget {
  @override
  _ModernChatScreenState createState() => _ModernChatScreenState();
}

class _ModernChatScreenState extends State<ModernChatScreen> {
  final ChatService chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isConnected = false;

  // Feature detection and responses
  final Map<String, Map<String, dynamic>> featureInfo = {
    'spell': {
      'keywords': ['spell', 'magic', 'magical', 'spells', 'casting', 'wizard'],
      'response': "Great question about our magical spell features! In SpeakSI, you can learn and cast spells using your voice. Our spell system helps you practice pronunciation while having fun with magic. Would you like to visit the spell casting area?",
      'navigationText': "Go to Spell Casting",
      'destination': (BuildContext context) => LvlScreen(initialPage: 0),
    },
    'voice': {
      'keywords': ['voice', 'speech', 'speak', 'recognition', 'talking', 'assistant', 'pronunciation'],
      'response': "I'd love to tell you about our voice recognition features! SpeakSI uses advanced voice recognition technology to help you practice speaking and improve your pronunciation. Would you like to try out the voice recognition system?",
      'navigationText': "Try Voice Recognition",
      'destination': (BuildContext context) => CombinedScreen(),
    },
  };

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    messages.add({
      'role': 'bot',
      'content': 'Welcome to SpeakSI! I can help you learn about our voice-powered features and magic spells. Feel free to ask about our spell casting or voice recognition features!',
      'showButton': false,
    });
  }

  String? _checkFeatureMatch(String message) {
    String messageLower = message.toLowerCase();
    for (var feature in featureInfo.keys) {
      if (featureInfo[feature]!['keywords'].any((keyword) => messageLower.contains(keyword))) {
        return feature;
      }
    }
    return null;
  }

  Future<void> _checkConnection() async {
    final isHealthy = await chatService.checkHealth();
    setState(() {
      _isConnected = isHealthy;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;
    if (!_isConnected) {
      _showErrorSnackBar('Not connected to server');
      return;
    }

    final userMessage = _controller.text;
    setState(() {
      messages.add({
        'role': 'user',
        'content': userMessage,
        'showButton': false,
      });
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    // Check for feature-related questions
    String? matchedFeature = _checkFeatureMatch(userMessage);
    if (matchedFeature != null) {
      setState(() {
        messages.add({
          'role': 'bot',
          'content': featureInfo[matchedFeature]!['response'],
          'showButton': true,
          'buttonText': featureInfo[matchedFeature]!['navigationText'],
          'navigation': featureInfo[matchedFeature]!['destination'],
        });
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    // Handle other queries through the chat service
    try {
      final response = await chatService.sendQuery(userMessage);
      setState(() {
        messages.add({
          'role': 'bot',
          'content': response['answer'],
          'showButton': false,
        });
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        messages.add({
          'role': 'bot',
          'content': 'Sorry, I encountered an error. Please try again.',
          'showButton': false,
        });
        _isLoading = false;
      });
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF101820),
              Color(0xFF1A1A1A),
            ],
            radius: 1.8,
            center: Alignment(0.8, -0.8),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Column(
                      crossAxisAlignment: message['role'] == 'user'
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        _buildMessageBubble(message)
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.2, duration: 300.ms),
                        if (message['showButton'] == true)
                          Padding(
                            padding: EdgeInsets.only(left: 48, top: 8, bottom: 12),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => message['navigation'](context),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                message['buttonText'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ).animate().fadeIn(delay: 500.ms).scale(),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.amber),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Speaki',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Icon(
            _isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: _isConnected ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: Colors.amber.withOpacity(0.2),
              child: Icon(Icons.assistant, color: Colors.amber),
            ),
          SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUser
                      ? [Colors.deepPurple, Colors.purple.shade900]
                      : [Colors.amber.withOpacity(0.2), Colors.amber.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message['content'],
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: Colors.deepPurple.withOpacity(0.2),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask about SpeakSI...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.5),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: Colors.black),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}