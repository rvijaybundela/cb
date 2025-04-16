import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/choose_auth_page.dart';
import 'package:provider/provider.dart';
import 'package:untitled/theme/theme_notifier.dart';
import 'dart:async'; // For Timer

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const CarbonShodhakApp(),
    ),
  );
}

class CarbonShodhakApp extends StatelessWidget {
  const CarbonShodhakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carbon Shodhak',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(), // Splash with JPG image
    );
  }
}

// SplashScreen using JPG instead of Lottie
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChooseAuthPage()),
      );
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand( // Makes it fill the entire screen
        child: Image.asset(
          'assets/images/carbon.jpg',
          fit: BoxFit.cover,  // Covers the screen, keeps aspect ratio
        ),
      ),
    );
  }
}

