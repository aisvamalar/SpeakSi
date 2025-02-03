import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path/path.dart';
import 'package:speaksi/screens/notification_manager.dart';
import 'package:speaksi/screens/profile_screen.dart';
import 'package:speaksi/screens/spell_screen.dart';
import 'package:speaksi/screens/voiceassistant_screen.dart';

import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    Center(child: Text('Statistics Page', style: TextStyle(color: Colors.amber))),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your chatbot navigation logic here
          // For example:
          Navigator.push(context, MaterialPageRoute(builder: (_) => ModernChatScreen()));
        },
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Icon(
              Icons.message_rounded,
              color: Colors.amber,
              size: 24,
            ),
          ),
        ),
      ).animate().scale(delay: 800.ms).fadeIn(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(Icons.home_rounded, "Home", 0),
            _buildNavBarItem(Icons.grade, "Statistics", 1),
            _buildNavBarItem(Icons.person, "Profile", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.amber,
              size: 24,
            ),
            if (isSelected) const SizedBox(width: 8),
            if (isSelected)
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.amber,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color(0xFF101820),
            Color(0xFF1A1A1A),
          ],
          radius: 1.8,
          center: Alignment(0.8, -0.8),
          stops: [0.2, 1.0],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 15),
                  _buildFeatureCards(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Welcome, Player!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 600.ms).moveY(begin: -20),
            CircleAvatar(
              backgroundColor: Colors.amber.withOpacity(0.2),
              radius: 25,
              child: IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: Colors.amber),
                onPressed: () {
                  Navigator.push(
                    context as BuildContext,
                    MaterialPageRoute(builder: (_) => NotificationManager()),
                  );
                },
            ).animate().fadeIn(delay: 400.ms).scale(),
            )
          ],

        ),
        const SizedBox(height: 0),
        Text(
          'Ready for today\'s voice adventures?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.blueGrey,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Path:',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height:5),
        _buildFeatureCard(
          context,
          'Speech Recognition',
          'images/img_2.png',
          CombinedScreen(),
          'Complete missions with your voice!',
          Icons.mic_rounded,
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          context,
          'Magic Spell',
          'images/img_12.png',
          LvlScreen(initialPage: 0), // Provide the required initialPage value
          'Unleash magical voice spells!',
          Icons.auto_awesome_rounded,
        ),

      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String imagePath,
      Widget destination, String description, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6A0572).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ).animate().scale(delay: 400.ms).fadeIn(duration: 500.ms),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.amber,
                    size: 30,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 700.ms).moveX(begin: 30);
  }
}
