import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(
      const Duration(seconds: 9),
          () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: Center(
        child: SizedBox(
          height: screenHeight * 0.5,
          width: screenWidth,
          child: Image.asset(
            'images/download-unscreen.gif',
            width: screenWidth,
            height: screenHeight,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
