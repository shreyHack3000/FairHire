import 'package:flutter/material.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const FairHireApp());
}

class FairHireApp extends StatelessWidget {
  const FairHireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FairHire — AI Bias Vulnerability Auditor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        primaryColor: const Color(0xFF6366F1),
        fontFamily: 'Segoe UI',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF8B5CF6),
          surface: Color(0xFF1E293B),
          background: Color(0xFF0B0F19),
          error: Color(0xFFEF4444),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
