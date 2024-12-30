import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_state.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserStats userStats = UserStats(
    conversationCount: 150,
    totalPoints: 750,
    achievements: [
      Achievement(
        name: "Conversation Starter",
        icon: "🏆",
        pointsRequired: 100,
        isUnlocked: true,
      ),
      Achievement(
        name: "Speech Master",
        icon: "🌟",
        pointsRequired: 500,
        isUnlocked: true,
      ),
      Achievement(
        name: "Language Expert",
        icon: "👑",
        pointsRequired: 1000,
        isUnlocked: false,
      ),
    ],
    currentLevel: "Advanced Speaker",
  );

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _handleSwitchAccount() {
    showDialog(
      context: context,
      builder: (context) => AccountSwitchDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildRewardsSection(),
            _buildAchievements(),
            _buildSubscriptionPlans(),
            _buildAccountControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade900, Colors.purple],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siddharth',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userStats.currentLevel,
                      style: TextStyle(
                        color: Colors.yellow[200],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildStatsBar(),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.purple.shade800,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Conversations', userStats.conversationCount.toString(), '🗣️'),
          _buildStatItem('Points', userStats.totalPoints.toString(), '⭐'),
          _buildStatItem('Trophies',
              userStats.achievements.where((a) => a.isUnlocked).length.toString(),
              '🏆'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String emoji) {
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Rewards',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          LinearProgressIndicator(
            value: userStats.totalPoints / 1000,
            backgroundColor: Colors.purple.shade700,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
          SizedBox(height: 10),
          Text(
            '${userStats.totalPoints} / 1000 points to next level',
            style: TextStyle(color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: userStats.achievements.map((achievement) {
              return _buildAchievementItem(achievement);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.purple.shade800 : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: achievement.isUnlocked ? Colors.purple.shade300 : Colors.grey.shade800,
        ),
      ),
      child: Column(
        children: [
          Text(
            achievement.icon,
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(height: 5),
          Text(
            achievement.name,
            style: TextStyle(
              color: achievement.isUnlocked ? Colors.white : Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            '${achievement.pointsRequired} pts',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Plans',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          _buildSubscriptionPlanItem('Basic Plan', 'Free', 'Access to basic features'),
          _buildSubscriptionPlanItem('Premium Plan', '\$9.99/month', 'Access to all features'),
          _buildSubscriptionPlanItem('Pro Plan', '\$19.99/month', 'Access to all features + priority support'),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlanItem(String title, String price, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.purple.shade800,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            price,
            style: TextStyle(
              color: Colors.yellow[200],
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountControls() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red.shade300),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleSwitchAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('Switch Account'),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountSwitchDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.purple.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Switch Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildAccountOption(context, 'Siddharth', 'Current Account'),
            _buildAccountOption(context, 'Work Account', 'Premium'),
            _buildAccountOption(context, 'Personal Account', 'Free'),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/add-account');
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.purple.shade300),
              ),
              child: Text(
                'Add Another Account',
                style: TextStyle(color: Colors.purple.shade300),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(BuildContext context, String name, String status) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple.shade300,
        child: Text(name[0], style: TextStyle(color: Colors.white)),
      ),
      title: Text(name, style: TextStyle(color: Colors.white)),
      subtitle: Text(status, style: TextStyle(color: Colors.grey)),
      onTap: () {
        // Handle account switch
        Navigator.pop(context);
      },
    );
  }
}