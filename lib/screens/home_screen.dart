import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:speaksi/screens/profile_screen.dart';
import 'package:speaksi/screens/recordingapp_screen.dart';
import 'package:speaksi/screens/spell_screen.dart';
import 'package:speaksi/screens/voiceassistant_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    RecordingScreen(),

    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SpeakSi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
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
      body: _pages[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.deepPurple,
        color: Colors.white,
        activeColor: Colors.amber,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.mic, title: 'Record'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFeatureCard(
            context,
            'Speech Recognition',
            'images/img_2.png',
            CombinedScreen(),
          ),
          SizedBox(height: 20),
          _buildFeatureCard(
            context,
            'Magic Spell',
            'images/img_4.png',
            SpellScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      String imagePath,
      Widget destination,
      ) {
    return Card(
      color: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF441D99), Color(0xFF6A35EE)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
