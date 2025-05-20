// This file will contain the SplashScreen widget 
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart';
import 'package:push_pal/src/features/auth/application/auth_service.dart'; // Import AuthService for provider
import 'package:push_pal/src/theme/app_theme.dart'; // To access colors

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
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

    // Navigate after a delay, checking auth state
    Future.delayed(const Duration(milliseconds: 2500), () { // Reduced delay slightly
      if (mounted) { 
        final user = ref.read(authStateChangesProvider).valueOrNull;
        if (user != null) {
          context.go('/'); // User is logged in, go to Home
        } else {
          context.go('/login'); // User is not logged in, go to Login
        }
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