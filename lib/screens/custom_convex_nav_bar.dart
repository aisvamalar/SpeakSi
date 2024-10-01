import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class CustomConvexBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomConvexBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      items: const [
        TabItem(icon: Icons.home, title: 'Home'),
        TabItem(icon: Icons.search, title: 'Speech'),
        TabItem(icon: Icons.person, title: 'Profile'),
      ],
      initialActiveIndex: currentIndex,
      onTap: onTap,
      style: TabStyle.fixed,
      elevation: 0, // Remove elevation for a flatter look
      gradient: LinearGradient(
        colors: [
          Color(0xFF441D99),
          Color(0xFF5737EE),
          Color(0xFF6A35EE),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      color: Colors.white, // Set icon color to white
      activeColor: Colors.white60, // Set active icon color to white
    );
  }
}
