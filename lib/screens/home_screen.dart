import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:speaksi/screens/profile_screen.dart';
import 'package:speaksi/screens/recordingapp_screen.dart';
import 'package:speaksi/screens/speech_recognition.dart';
import 'package:speaksi/screens/spell_screen.dart';
import 'package:speaksi/screens/voiceassistant_screen.dart';

import '../widget/tapandspeakmodel.dart';
import 'magic_spell_screen.dart'; // Import the custom widget
import 'custom_convex_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Define a list of pages to navigate
  final List<Widget> _pages = [
    HomeContent(),
    RecordingApp(),


    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage('https://i.imgur.com/BoN9kdC.png'),
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex], // Display the currently selected page

      // Use the shared ConvexAppBar for the bottom navigation
      bottomNavigationBar: CustomConvexBottomBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Update the tab index when tapped
          });
        },
      ),
    );
  }
}


// Home content widget
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Speech Recognition Container
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VoiceAssistantScreen()),
            ); // Navigate to TapAndSpeakScreen when this is pressed

          },
          child: _buildContainer('Speech recognition', 'images/img_2.png'),
        ),
        // Magic Spell Container
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SpellScreen()),
            );
          },
          child: _buildContainer('Magic spell', 'images/img_4.png'),
        ),
      ],
    );
  }

  Widget _buildContainer(String title, String imagePath) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 250,
              width: 400,
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF441D99),
                    Color(0xFF5737EE),
                    Color(0xFF6A35EE),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
