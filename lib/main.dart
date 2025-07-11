import 'package:flutter/material.dart';
import 'screens/SplashScreen.dart'; // ✅ Import SplashScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: const SplashScreen(), // ✅ Show splash first
    );
  }
}
