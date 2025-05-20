// This file will contain the SplashScreen widget 
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:push_pal/src/theme/app_theme.dart'; // To access colors

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
      duration: const Duration(milliseconds: 1500), // Animation duration
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Navigate after a delay
    Timer(const Duration(seconds: 3), () {
      if (mounted) { // Check if the widget is still in the tree
        // In the future, this will check auth state
        context.go('/'); // Navigate to HomeScreen (or login/home based on auth state later)
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryOrange, // Using the theme's primary orange
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text-based logo concept
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: appWhite, 
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black26,
                          offset: Offset(2.0, 2.0),
                        ),
                      ]
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Push'),
                      TextSpan(
                        text: 'Pal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600, // Slightly less bold for "Pal"
                          // You could add a very slight color difference here if desired
                          // e.g., color: appWhite.withOpacity(0.9)
                        ),
                      ),
                    ],
                  ),
                ),
                // Optional: A subtle icon below
                // const SizedBox(height: 16),
                // Icon(Icons.fitness_center, color: appWhite.withOpacity(0.8), size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 