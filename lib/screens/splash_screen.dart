import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to LoginScreen after 9 seconds
    Timer(
      const Duration(seconds: 9),
          () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: Center(
        child: SizedBox(
          height: screenHeight * 0.5, // 50% of the screen height
          width: screenWidth, // Full screen width
          child: Image.asset(
            'images/download-unscreen.gif', // Path to the GIF
            fit: BoxFit.cover, // Fill the container
          ),
        ),
      ),
    );
  }
}
