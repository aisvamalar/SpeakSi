import 'package:flutter/material.dart';

void main() => runApp(RecordingApp());

class RecordingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RecordingScreen(),
    );
  }
}

class RecordingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Column(
        children: [
          // Top section with only the microphone icon
          _buildTopSection(),
          SizedBox(height: 20),
          // Texts "Siddhu’s recordings" and "Chill your mind" below the container
          _buildTextSection(),
          SizedBox(height: 30), // Increased spacing between the texts and recordings
          // List of recordings below the texts
          _buildRecordingList(),
        ],
      ),

    );
  }

  Widget _buildTopSection() {
    return Container(
      height: 200, // Height of the top section
      width: double.infinity, // Full width of the screen
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade900, Colors.purple],
        ),
        borderRadius: BorderRadius.only(
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
                width: 120, // Width of the circle container
                height: 200, // Adjusted height for the circle container
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.purple.shade700, Colors.purple.shade900],
                  ),
                ),
              ),
              Icon(Icons.mic, size: 60, color: Colors.white), // Mic icon
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Siddhu’s recordings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5), // Spacing between the two texts
              Text(
                "Chill your mind",
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildCircularButton(Icons.play_arrow),
              SizedBox(width: 10), // Spacing between the buttons
              _buildCircularButton(Icons.favorite),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.purple.shade300,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildRecordingList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 6, // Total recordings
        itemBuilder: (context, index) {
          return _buildRecordingItem(index + 1);
        },
      ),
    );
  }

  Widget _buildRecordingItem(int recordingNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40, // Width of the mic icon
            child: Icon(Icons.mic, color: Colors.purple[300], size: 30),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              "Rec 0$recordingNumber",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Text(
            _getDuration(recordingNumber),
            style: TextStyle(color: Colors.grey[300]),
          ),
          SizedBox(width: 20),
          Icon(Icons.play_arrow, color: Colors.white),
        ],
      ),
    );
  }

  String _getDuration(int recordingNumber) {
    // You can replace these with actual recording durations
    List<String> durations = ["3:58", "3:03", "3:51", "4:52", "2:09", "3:56"];
    return durations[recordingNumber - 1];
  }


  }
