import 'package:flutter/material.dart';

import 'package:speaksi/screens/spell_screen.dart'; // Ensure this is correct

class AchievementScreen extends StatelessWidget {
  final int level;
  final Function(int) onLevelComplete;

  const AchievementScreen({
    Key? key,
    required this.level,
    required this.onLevelComplete, required Null Function() onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            GestureDetector(
              onTap: () {
                onLevelComplete(level); // Unlock the next level
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LvlScreen(initialPage: level), // Navigate to the next level
                  ),
                      (route) => false,
                );
              },

              child: Image.asset(
                'images/achiveee.gif', // Replace with your actual GIF path
                width: 500,
                height: 500,
              ),
            ),


          ],
        ),
      ),
    );
  }
}
