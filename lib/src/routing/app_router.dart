import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:push_pal/main.dart'; // Old import for HomeScreen
import 'package:push_pal/src/features/home/presentation/home_screen.dart'; // New import for HomeScreen
import 'package:push_pal/src/features/splash/presentation/splash_screen.dart'; // Import SplashScreen
import 'package:push_pal/src/features/auth/presentation/login_screen.dart'; // Import LoginScreen
import 'package:push_pal/src/features/auth/presentation/signup_screen.dart'; // Import SignupScreen

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
// final _shellNavigatorKey = GlobalKey<NavigatorState>(); // Example for shell routes later

final appRouter = GoRouter(
  initialLocation: '/splash', // Updated: Start with the splash screen
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true, // Useful for debugging, can be removed in production
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/', // HomeScreen remains at the root path for now
      name: 'home',
      builder: (context, state) => const HomeScreen(), // Points to the HomeScreen from its new file
      // TODO: Later, add a redirect from '/' based on auth state if needed,
      // or make sure splash screen always handles the initial auth check and redirect.
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    // TODO: Add more routes and sub-routes as features are developed
    // routes: [
    //   GoRoute(
    //     path: 'profile',
    //     name: 'profile',
    //     builder: (context, state) => const ProfileScreen(),
    //   ),
    // ],
  ],
  // TODO: Implement error handling for routes not found
  // errorBuilder: (context, state) => const NotFoundScreen(),
);

// HomeScreen has been moved to its own file. 