import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:speaksi/screens/signup_screen.dart';
import 'package:speaksi/screens/toast.dart';
import 'home_screen.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  bool _isSigning = false;
  SharedPreferences? sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkAuthenticationStatus();
  }

  void checkAuthenticationStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    bool isLoggedIn = sharedPreferences!.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate()
                    .fadeIn(duration: 1000.ms)
                    .slideY(begin: 1.0, end: 0.0, curve: Curves.easeInOut)
                    .then(delay: 500.ms),
                const SizedBox(height: 12),
                const Text(
                  'Welcome back, we missed you',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 60),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.email, color: Colors.grey),
                          fillColor: Colors.grey[800],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                          fillColor: Colors.grey[800],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSigning ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B3DFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          child: _isSigning
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Log in', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text('Or continue with', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialLoginButton('images/img_1.png'),
                          const SizedBox(width: 16),
                          _buildSocialLoginButton('images/img_3.png'),
                          const SizedBox(width: 16),
                          _buildSocialLoginButton('images/img.png'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?", style: TextStyle(color: Colors.grey)),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => SignupScreen()),
                              );
                            },
                            child: const Text('Sign up', style: TextStyle(color: Color(0xFF7B3DFF))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton(String imagePath) {
    return InkWell(
      onTap: _signInWithGoogle,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[800],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(imagePath),
        ),
      ),
    );
  }
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSigning = true;
      });

      try {
        final email = _emailController.text;
        final password = _passwordController.text;

        // Directly authenticate using Supabase Auth
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          sharedPreferences!.setBool('isLoggedIn', true);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => HomeScreen()),
          );
        } else {
          showToast(message: 'Login failed. Please check your credentials.');
        }
      } catch (e) {
        showToast(message: e.toString());
      } finally {
        setState(() {
          _isSigning = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigning = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential.user != null) {
        sharedPreferences!.setBool('isLoggedIn', true);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => HomeScreen()),
        );
      }
    } catch (e) {
      showToast(message: e.toString());
    } finally {
      setState(() {
        _isSigning = false;
      });
    }
  }
}