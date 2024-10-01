import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';




class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5737EE),
        title: Text("Home"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Add back navigation logic here
          },
        ),
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage("https://your-profile-image-url-here.com"), // Replace with user image
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Speech Recognition Section
              GestureDetector(
                onTap: () {
                  // Navigate to Speech Recognition page
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'images/img_2.png', // Replace with actual image
                        height: 150,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Speech Recognition",
                        style: TextStyle(
                          color: Color(0xFF441D99),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Magic Spell Section
              GestureDetector(
                onTap: () {
                  // Navigate to Magic Spell page
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                      SizedBox(height: 10),
                      Image.network(
                        'https://your-second-image-url-here.com', // Replace with actual image
                        height: 150,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Magic Spell",
                        style: TextStyle(
                          color: Color(0xFF5737EE),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Color(0xFF5737EE),
          ),

          /// Learning
          SalomonBottomBarItem(
            icon: Icon(Icons.school),
            title: Text("Learning"),
            selectedColor: Color(0xFF5737EE),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Color(0xFF5737EE),
          ),
        ],
      ),
    );
  }
}