// File: lib/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const SplashScreen({super.key, required this.toggleTheme});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Memulai seluruh urutan animasi dan navigasi
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    try {
      // 1. Jalankan animasi 'muncul' (fade-in & scale-up) dan tunggu hingga selesai
      await _animationController.forward().orCancel;

      // 2. Beri jeda sejenak setelah logo muncul
      await Future.delayed(const Duration(milliseconds: 800));

      // Pastikan widget masih ada di tree sebelum melakukan navigasi
      if (!mounted) return;

      // 3. Mulai navigasi ke halaman login.
      //    Animasi 'menghilang' akan dijalankan setelah ini untuk efek cross-fade.
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(toggleTheme: widget.toggleTheme),
          // Durasi transisi fade-in untuk halaman login
          transitionDuration: const Duration(milliseconds: 1000),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
              child: child,
            );
          },
        ),
      );

      // 4. Jalankan animasi 'menghilang' (fade-out & scale-down) pada logo splash screen
      _animationController.reverse();

    } on TickerCanceled {
      // Exception ini akan muncul jika widget di-dispose saat animasi masih berjalan.
      // Kita bisa mengabaikannya dengan aman dalam kasus ini.
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Lenovo_Global_Corporate_Logo.png/1280px-Lenovo_Global_Corporate_Logo.png',
                  height: 80,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'Lenovo',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Copyright © 2024 Putera',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}