import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/Splash/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Student App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}