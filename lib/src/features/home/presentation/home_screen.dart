import 'package:flutter/material.dart';

// This HomeScreen is now routed to by GoRouter.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PushPal Home'), // Will use AppBarTheme from app_theme.dart
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to PushPal! Authentication coming soon.',
              // style: Theme.of(context).textTheme.bodyLarge, // Example of using themed text
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Sample Button'), // Will use ElevatedButtonTheme
            )
          ],
        ),
      ),
    );
  }
} 