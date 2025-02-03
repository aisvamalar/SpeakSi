import 'package:flutter/material.dart';
import 'package:speaksi/screens/HearingAid_screen.dart';

import 'battery_screen.dart';



class SetScreen extends StatelessWidget {
  const SetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4823A7),
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Set Remainder',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('images/img_14.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedFeatureCard(
              title: 'Battery Care',
              imagePath: 'images/img_14.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BatteryScreen()),
                );
// Handle Battery Care tap
              },
              delay: const Duration(milliseconds: 200),
            ),
            const SizedBox(height: 24),
            _buildAnimatedFeatureCard(
              title: 'AidClean',
              imagePath: 'images/img_15.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HearingAidScreen()),
                );// Navigator.push(
                ////context,
                ////  MaterialPageRoute(builder: (context) => SetScreen()),
                //    );
                // Handle AidClean tap
              },
              delay: const Duration(milliseconds: 400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedFeatureCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
    required Duration delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildFeatureCard(
              title: title,
              imagePath: imagePath,
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Slightly lighter for visibility
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4823A7).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTapDown: (_) => onTap(),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 220,
                    // Increased height for a larger image
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4823A7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}