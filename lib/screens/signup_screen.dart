import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speaksi/screens/home_screen.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // Add back navigation
                },
              ),
              SizedBox(height: 60), // Added space between the texts

              // Animated "Get Started" text
              Center(
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  .animate() // Start animation here
                  .fadeIn(duration: 1000.ms) // Fade-in effect
                  .slideY(begin: 1.0, end: 0.0, curve: Curves.easeInOut) // Slide-in effect from bottom
                  .then(delay: 500.ms) ,// Delay between animations

              SizedBox(height: 50),
              // Email Field
              Text(
                'Email Address',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              _buildInputField(
                controller: _emailController,
                hintText: 'yourname@email.com',
                icon: Icons.email,
              ),
              SizedBox(height: 20),
              // Username Field
              Text(
                'Username',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              _buildInputField(
                controller: _usernameController,
                hintText: 'yourname',
                icon: Icons.person,
              ),
              SizedBox(height: 20),
              // Password Field
              Text(
                'Password',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              _buildPasswordField(
                controller: _passwordController,
                hintText: '••••••••',
              ),

              SizedBox(height: 60),
              // Sign up Button
              Center(
                child: SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => HomeScreen()),
                      );// Sign up functionality
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Color(0xFF7B3DFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: Text(
                  'Or continue with',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialLoginButton('images/img_3.png',),
                    SizedBox(width: 16),
                    _buildSocialLoginButton('images/img.png'),
                    SizedBox(width: 16),
                    _buildSocialLoginButton('images/img_1.png'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Input Field Builder
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Password Field Builder
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.lock, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Social Media Login Button
  Widget _buildSocialLoginButton(String imagePath) {
    return InkWell(
      onTap: () {
        // Add social login functionality
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[900],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(imagePath), // Ensure these images are in your assets folder
        ),
      ),
    );
  }
}