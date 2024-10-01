import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Picture and Name with Gradient
            Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4515AA), Color(0xFF7B40F9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/300', // Replace with actual profile image URL
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Siddharth',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Beginner',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Add functionality for subscribing
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      backgroundColor: Color(0xFFFCE202),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Subscribe to Premium',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Why join premium box with better layout
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFF7B40F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Why Join Premium?',
                    style: TextStyle(
                      color: Color(0xFFFCE202),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildPremiumFeature(Icons.check_circle, 'Unlimited conversations'),
                  _buildPremiumFeature(Icons.check_circle, 'Ads-Free'),
                  _buildPremiumFeature(Icons.check_circle, 'Progress monitoring'),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Support box
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFF9917FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Facing any issues?\nLive chat with one of our representatives.',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),

            // Subscription plans with better spacing and layout
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Plans',
                    style: TextStyle(
                        color: Color(0xFFFCE202),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPlanButton('₹415/month', Color(0xFF7B40F9)),
                          _buildPlanButton('₹4,980/year', Color(0xFF7B40F9)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPlanButton('₹120/week', Color(0xFF7B40F9)),
                          _buildPlanButton('₹25/day', Color(0xFF7B40F9)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Bottom buttons with better alignment and design
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBottomButton('Logout', Icons.logout, context),
                  _buildBottomButton('Switch Accounts', Icons.switch_account, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanButton(String text, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(String text, IconData icon, BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF7B40F9), size: 30),
        SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(color: Color(0xFF7B40F9), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildPremiumFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFCE202)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}