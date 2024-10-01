import 'package:flutter/material.dart';

class SpellScreen extends StatefulWidget {
  @override
  _SpellScreenState createState() => _SpellScreenState();
}

class _SpellScreenState extends State<SpellScreen> with SingleTickerProviderStateMixin {
  double _imageOpacity = 0.0; // Initially, image is invisible

  @override
  void initState() {
    super.initState();
    // Start the animation after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _imageOpacity = 1.0; // Make the image fully visible
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            // Add back navigation logic here
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.white,
            onPressed: () {
              // Add menu button logic here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20), // Top padding for spacing
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "SPELL",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "CHALLENGE",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Gradient "Word of the Day" Box
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  "WORD OF THE DAY",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Animated Mushroom Image
              AnimatedOpacity(
                opacity: _imageOpacity,
                duration: Duration(seconds: 1), // Duration for fade-in effect
                child: Image.asset(
                  'images/img_6.png', // Update with the actual asset path
                  width: 200,
                  height: 200,
                ),
              ),
              SizedBox(height: 20),

              // Word Display ("Mushroom" text)
              Text(
                "Mushroom",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 70),

              // Tap to Speak Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    // Add microphone action logic here
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Tap to Speak ✨",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
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
    );
  }
}