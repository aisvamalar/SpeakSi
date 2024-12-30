import 'package:flutter/material.dart';
import 'package:speaksi/screens/profile_screen.dart';
import 'package:speaksi/screens/recordingapp_screen.dart';
import 'package:speaksi/screens/voiceassistant_screen.dart';

class YourWordsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: 50),
          _buildTopBar(),
          SizedBox(height: 50),
          _buildContentBox(context),
          Spacer(),
          _buildImageWidget(context),  // Adding the image widget with navigation
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your words',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Chill your mind',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildContentBox(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF7B3CF1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildWordItem('The sun rises in the east'),
          _buildWordItem('It was a delicious food'),
          _buildWordItem('Everything is impermanent'),
          _buildWordItem('Positive energy inspires'),
          _buildWordItem('Impermanence leads to suffering'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.copy, color: Colors.tealAccent, size: 32),
                onPressed: () {
                  // Action for copy icon
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6610F2),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Save',
                    style: TextStyle(fontSize: 18, color: Colors.white,)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecordingScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.yellowAccent, size: 32),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CombinedScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWordItem(String word) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.tealAccent),
          SizedBox(width: 10),
          Text(
            word,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // Image widget with navigation on tap
  Widget _buildImageWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CombinedScreen()),
          );
        },
        child: Image.asset(
          'images/img_11.png',  // Path to your image
          height: 250,
          width: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
