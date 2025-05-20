import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart';
import 'package:push_pal/src/features/auth/application/auth_service.dart'; // For authStateChangesProvider
import 'package:push_pal/src/features/auth/application/user_profile_service.dart'; // For profile provider
import 'package:push_pal/src/features/auth/domain/user_profile.dart'; // For UserProfile type
// import 'package:push_pal/main.dart'; // Old import for HomeScreen
import 'package:push_pal/src/features/home/presentation/home_screen.dart'; // New import for HomeScreen
import 'package:push_pal/src/features/splash/presentation/splash_screen.dart'; // Import SplashScreen
import 'package:push_pal/src/features/auth/presentation/login_screen.dart'; // Import LoginScreen
import 'package:push_pal/src/features/auth/presentation/signup_screen.dart'; // Import SignupScreen
import 'package:push_pal/src/features/auth/presentation/create_profile_screen.dart'; // Import CreateProfileScreen
import 'package:push_pal/src/features/auth/presentation/availability_screen.dart'; // Import AvailabilityScreen

// Provider to track if the minimum splash screen time has elapsed
final splashMinTimeElapsedProvider = StateProvider<bool>((ref) => false);

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
// final _shellNavigatorKey = GlobalKey<NavigatorState>(); // Example for shell routes later

// This notifier is used to refresh the router when auth state changes.
// It should be provided globally if your GoRouter instance is global.
// For simplicity here, if appRouter is global, this can be too.
// Alternatively, pass Riverpod's Ref to GoRouter to listen directly.

// We need a way to access the Riverpod container or a Ref to read authStateChangesProvider
// If GoRouter is instantiated in a place where Ref is available (e.g., inside a ConsumerWidget build method
// or by passing the ProviderContainer), that's cleaner.
// For a globally defined router, this is a common pattern:

// 1. Create a Riverpod provider for GoRouter itself, so it can access other providers.

final goRouterProvider = Provider<GoRouter>((ref) {
  print('[GoRouterProvider BUILDER] Running. Listening to provider changes.');

  final authState = ref.watch(authStateChangesProvider);
  final profileState = ref.watch(currentUserProfileStreamProvider);
  final minSplashTimeElapsed = ref.watch(
    splashMinTimeElapsedProvider,
  ); // Watch the new provider

  final UserProfile? watchedProfile = profileState.valueOrNull;
  final bool watchedProfileComplete =
      watchedProfile?.profileSetupComplete ?? false;
  print(
    '[GoRouterProvider BUILDER] Watched authState loading: ${authState.isLoading}, hasValue: ${authState.hasValue}',
  );
  print(
    '[GoRouterProvider BUILDER] Watched profileState loading: ${profileState.isLoading}, hasValue: ${profileState.hasValue}, value: ${watchedProfile?.toMap()}, isComplete: $watchedProfileComplete',
  );

  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.valueOrNull != null;
      final UserProfile? userProfile = profileState.valueOrNull;
      final bool isProfileSetupComplete =
          userProfile?.profileSetupComplete ?? false;
      // Helper to check if core profile fields are filled (excluding availability)
      final bool areCoreProfileFieldsFilled =
          userProfile != null &&
          userProfile.displayName != null &&
          !userProfile.displayName!.isEmpty &&
          userProfile.fitnessGoal != null &&
          !userProfile.fitnessGoal!.isEmpty &&
          userProfile.gender != null &&
          !userProfile.gender!.isEmpty &&
          userProfile.dateOfBirth != null &&
          userProfile.locationZipCode != null &&
          !userProfile.locationZipCode!.isEmpty &&
          userProfile.preferredWorkoutTypes != null &&
          userProfile.preferredWorkoutTypes!.isNotEmpty;

      final bool actualMinSplashTimeElapsed = ref.read(
        splashMinTimeElapsedProvider,
      );

      final String currentLocation = state.matchedLocation;

      print(
        '[GoRouter Redirect] Current: $currentLocation, AuthLoading: ${authState.isLoading}, ProfileLoading: ${profileState.isLoading}, LoggedIn: $isLoggedIn, ProfileComplete: $isProfileSetupComplete, SplashTimeElapsed: $actualMinSplashTimeElapsed',
      );

      // If auth or profile is loading OR min splash time NOT elapsed, and we are on splash, stay on splash
      if (currentLocation == '/splash' &&
          ((authState.isLoading ||
                  (isLoggedIn &&
                      profileState.isLoading &&
                      userProfile == null)) ||
              !actualMinSplashTimeElapsed)) {
        print(
          '[GoRouter Redirect] Auth/Profile loading or min splash time not elapsed, staying on splash.',
        );
        return null;
      }

      // Logic for navigating away from splash once auth (and profile if logged in) is determined AND min time elapsed
      if (currentLocation == '/splash' && actualMinSplashTimeElapsed) {
        if (!authState.isLoading) {
          if (!isLoggedIn) {
            print('[GoRouter Redirect] From Splash: Not logged in -> /login');
            return '/login';
          } else {
            if (!profileState.isLoading || userProfile != null) {
              if (isProfileSetupComplete) {
                print(
                  '[GoRouter Redirect] From Splash: Logged in, profile complete -> /',
                );
                return '/';
              } else if (areCoreProfileFieldsFilled) {
                print(
                  '[GoRouter Redirect] From Splash: Logged in, core profile filled, needs availability -> /set-availability',
                );
                return '/set-availability';
              } else {
                print(
                  '[GoRouter Redirect] From Splash: Logged in, profile INCOMPLETE -> /create-profile',
                );
                return '/create-profile';
              }
            } else {
              // Profile is still loading, stay on splash (this case should be covered by the initial loading check)
              print(
                '[GoRouter Redirect] From Splash: Logged in, but profile still loading, staying splash (should be rare here)',
              );
              return null;
            }
          }
        }
        return null; // Auth still loading, stay on splash
      }

      // --- Regular route protection after splash ---
      if (!isLoggedIn) {
        // If not logged in, allow only login, signup
        if (currentLocation != '/login' && currentLocation != '/signup') {
          print(
            '[GoRouter Redirect] Not logged in & not on auth pages -> /login',
          );
          return '/login';
        }
      } else {
        // User is logged in
        if (!isProfileSetupComplete) {
          if (currentLocation == '/create-profile' ||
              currentLocation == '/set-availability') {
            return null; // Allow staying on these pages if profile is not complete
          }
          if (!areCoreProfileFieldsFilled) {
            print(
              '[GoRouter Redirect] Logged in, core profile INCOMPLETE -> /create-profile',
            );
            return '/create-profile';
          }
          // Core fields are filled, but profile setup is not complete (means availability is next)
          print(
            '[GoRouter Redirect] Logged in, core profile complete, needs availability -> /set-availability',
          );
          return '/set-availability';
        }

        // If profile IS complete, and user is on login, signup, create-profile, or set-availability, redirect to home
        if (isProfileSetupComplete &&
            (currentLocation == '/login' ||
                currentLocation == '/signup' ||
                currentLocation == '/create-profile' ||
                currentLocation == '/set-availability')) {
          print(
            '[GoRouter Redirect] Logged in, profile COMPLETE, but on auth/setup page -> /',
          );
          return '/';
        }
      }
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
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
      GoRoute(
        path: '/create-profile',
        name: 'createProfile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      GoRoute(
        // Add route for AvailabilityScreen
        path: '/set-availability',
        name: 'setAvailability',
        builder: (context, state) => const AvailabilityScreen(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Text('Error: ${state.error?.message ?? 'Page not found'}'),
          ),
        ),
  );
});

// Helper class to convert a Stream to a Listenable for GoRouter's refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// HomeScreen has been moved to its own file.
