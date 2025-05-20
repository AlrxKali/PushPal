import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:push_pal/main.dart'; // Importing HomeScreen from main.dart for now

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
// final _shellNavigatorKey = GlobalKey<NavigatorState>(); // Example for shell routes later

final appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true, // Useful for debugging, can be removed in production
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(), // Points to the existing HomeScreen
      // TODO: Add more routes and sub-routes as features are developed
      // routes: [
      //   GoRoute(
      //     path: 'profile',
      //     name: 'profile',
      //     builder: (context, state) => const ProfileScreen(),
      //   ),
      // ],
    ),
  ],
  // TODO: Implement error handling for routes not found
  // errorBuilder: (context, state) => const NotFoundScreen(),
);

// TODO: Consider moving HomeScreen to its own file, e.g., lib/src/features/home/presentation/home_screen.dart 