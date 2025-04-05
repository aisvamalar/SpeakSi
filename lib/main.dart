import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for SystemChrome
import 'package:firebase_core/firebase_core.dart';
import 'package:speaksi/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );


  await Supabase.initialize(
    url: 'https://zbqtsfvwfsdyzsbfbwys.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpicXRzZnZ3ZnNkeXpzYmZid3lzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc1Mjc0NTIsImV4cCI6MjA1MzEwMzQ1Mn0.QBo3D2O3iWNR-0A3mP98sdQ7KMMNNhwSTH4zjHN8vkA',
  );
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Run the app
  runApp(VoiceRecorderApp());
}

class VoiceRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Recorder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.purple,
          inactiveTrackColor: Colors.purple.withOpacity(0.3),
          thumbColor: Colors.purple,
          trackHeight: 4.0,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
