import 'package:flutter/material.dart';
import 'package:fairhire_app/theme/app_theme.dart';
import 'package:fairhire_app/screens/login_screen.dart';
import 'package:fairhire_app/screens/upload_screen.dart';
import 'package:fairhire_app/screens/report_screen.dart';
import 'package:fairhire_app/screens/history_screen.dart';

void main() {
  runApp(const FairHireApp());
}

class FairHireApp extends StatelessWidget {
  const FairHireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FairHire — Bias Auditor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/upload': (context) => const UploadScreen(),
        '/report': (context) => const ReportScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
