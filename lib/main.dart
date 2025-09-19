// File: lib/main.dart
import 'package:flutter/material.dart';
import 'utility/app_theme.dart';
import 'utility/splash_screen.dart'; //

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      // Ganti AuthScreen dengan SplashScreen sebagai halaman utama
      home: SplashScreen(
        toggleTheme: _toggleTheme,
      ),
    );
  }
}