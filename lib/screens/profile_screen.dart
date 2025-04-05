import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:speaksi/screens/login_screen.dart';
import 'package:speaksi/screens/set_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  // Future method to handle logout
  Future<void> _handleLogout() async {
    try {
      // Sign out from Supabase first
      await supabase.auth.signOut();

      // Clear local storage after successful sign out
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to handle account switching
  void _handleSwitchAccount() {
    showDialog(
      context: context,
      builder: (context) => const AccountSwitchDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2A0845),
              const Color(0xFF18042B),
              Colors.black.withOpacity(0.95),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _buildAnimatedProfileSection(),
                  const SizedBox(height: 25),
                  _buildAnimatedButton(
                    text: 'Subscribe to Premium',
                    icon: Icons.star,
                    color: const Color(0xFFFFB800),
                    textColor: Colors.black,
                    onPressed: () {},
                    delay: 200,
                  ),
                  const SizedBox(height: 15),
                  _buildAnimatedButton(
                    text: 'Set Reminder',
                    icon: Icons.notifications_active_outlined,
                    color: Colors.transparent,
                    borderColor: Colors.white,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetScreen()),
                      );
                    },
                    delay: 400,
                  ),
                  const SizedBox(height: 30),
                  _buildAnimatedFeaturesSection(),
                  const SizedBox(height: 25),
                  _buildAnimatedSupportSection(),
                  const SizedBox(height: 30),
                  _buildAnimatedPlansSection(),
                  const SizedBox(height: 30),
                  _buildAnimatedBottomButtons(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedProfileSection() {
    // Get user data from Supabase
    final user = supabase.auth.currentUser;
    final userEmail = user?.email ?? 'No email';
    final userName = user?.userMetadata?['name'] ?? userEmail.split('@')[0];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6A1B9A),
                    const Color(0xFF4A148C).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.shade900.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildGlowingAvatar(),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${userName.toLowerCase()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowingAvatar() {
    final user = supabase.auth.currentUser;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[300],
        backgroundImage: user?.userMetadata?['avatar_url'] != null
            ? NetworkImage(user!.userMetadata!['avatar_url']) as ImageProvider
            : null,
        child: user?.userMetadata?['avatar_url'] == null
            ? const Icon(Icons.person, size: 30, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required IconData icon,
    required Color color,
    Color? textColor,
    Color? borderColor,
    required VoidCallback onPressed,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildNeonButton(
              text: text,
              icon: icon,
              color: color,
              textColor: textColor,
              borderColor: borderColor,
              onPressed: onPressed,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeonButton({
    required String text,
    required IconData icon,
    required Color color,
    Color? textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          if (color != Colors.transparent)
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: color == Colors.transparent ? 0 : 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedFeaturesSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6A1B9A),
                    const Color(0xFF4A148C).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.shade900.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why join Premium?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildFeatureRow(Icons.check_circle_outline, 'Unlimited conversations'),
                  const SizedBox(height: 20),
                  _buildFeatureRow(Icons.check_circle_outline, 'Ad-Free Experience'),
                  const SizedBox(height: 20),
                  _buildFeatureRow(Icons.check_circle_outline, 'Regular monitoring'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSupportSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6A1B9A),
                    const Color(0xFF4A148C).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.shade900.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.grey),
                  SizedBox(width: 12),
                  Text(
                    'Facing any issues?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedPlansSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available plans',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildNeonButton(
                        text: '₹4,840/year',
                        icon: Icons.calendar_today_outlined,
                        color: const Color(0xFFFFB800),
                        textColor: Colors.black,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNeonButton(
                        text: '₹420/month',
                        icon: Icons.calendar_view_month,
                        color: const Color(0xFFFFB800),
                        textColor: Colors.black,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildNeonButton(
                        text: '₹120/week',
                        icon: Icons.calendar_view_week,
                        color: Colors.transparent,
                        borderColor: Colors.white,
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNeonButton(
                        text: '₹25/day',
                        icon: Icons.calendar_today,
                        color: Colors.transparent,
                        borderColor: Colors.white,
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBottomButtons() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                Expanded(
                  child: _buildNeonButton(
                    text: 'Logout',
                    icon: Icons.logout,
                    color: Colors.transparent,
                    borderColor: Colors.white,
                    textColor: Colors.white,
                    onPressed: _handleLogout, // Using the logout function here
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNeonButton(
                    text: 'Switch Accounts',
                    icon: Icons.swap_horiz,
                    color: const Color(0xFF6A1B9A),
                    textColor: Colors.white,
                    onPressed: _handleSwitchAccount, // Using the switch account function here
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFFB800),
            size: 22,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class AccountSwitchDialog extends StatelessWidget {
  const AccountSwitchDialog({Key? key}) : super(key: key);

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
            const Text(
              'Switch Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildAccountOption(context, 'Siddharth', 'Current Account'),
            _buildAccountOption(context, 'Work Account', 'Premium'),
            _buildAccountOption(context, 'Personal Account', 'Free'),
            const SizedBox(height: 10),
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
        child: Text(name[0], style: const TextStyle(color: Colors.white)),
      ),
      title: Text(name, style: const TextStyle(color: Colors.white)),
      subtitle: Text(status, style: const TextStyle(color: Colors.grey)),
      onTap: () {
        // Handle account switch
        Navigator.pop(context);
      },
    );
  }
}