import 'package:flutter/material.dart';
import 'package:speaksi/screens/yourwords_screen.dart';


class VoiceAssistantScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF3A007B), // Purple gradient color
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text elements: 'Tap & Speak' and 'Let's start!'
            Padding(
              padding: const EdgeInsets.only(bottom: 0.0,top: 30),
              child: Column(
                children: [
                  Text(
                    'Tap & Speak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Let's start!",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Sound wave and mic icon
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Microphone icon at the center
                    Image.asset(
                      'images/img_7.png', // First asset image (replace with your asset path)
                      width: 300,
                      height: 300,
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: 0),
            // Bottom mic button with glowing effect, adding navigation
            GestureDetector(
              onTap: () {
                // Navigate to the next screen when the mic is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.purpleAccent, Colors.black],
                    center: Alignment.center,
                    radius: 0.3,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Image.asset(
                    'images/img_8.png', // Second mic icon at the bottom (replace with your asset path)
                    width: 500,
                    height: 350,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy new screen for navigation
class NewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF3A007B), // Purple gradient color
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text elements: 'Tap & Speak' and 'Let's start!'
            Padding(
              padding: const EdgeInsets.only(bottom: 0.0,top: 30),
              child: Column(
                children: [
                  Text(
                    'We are Listneing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Let's start!",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Sound wave and mic icon
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Microphone icon at the center
                    Image.asset(
                      'images/img_9.png', // First asset image (replace with your asset path)
                      width: 300,
                      height: 300,
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: 0),
            // Bottom mic button with glowing effect, adding navigation
            GestureDetector(
              onTap: () {
                // Navigate to the next screen when the mic is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => YourWordsScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.purpleAccent, Colors.black],
                    center: Alignment.center,
                    radius: 0.3,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Image.asset(
                    'images/img_10.png', // Second mic icon at the bottom (replace with your asset path)
                    width: 500,
                    height: 350,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
