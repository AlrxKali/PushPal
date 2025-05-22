import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_pal/src/features/auth/application/auth_service.dart';
import 'package:push_pal/src/features/auth/application/user_profile_service.dart';
import 'package:push_pal/src/features/auth/domain/user_profile.dart';
import 'package:go_router/go_router.dart'; // For potential navigation or logout

// This HomeScreen is now routed to by GoRouter.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsyncValue = ref.watch(currentUserProfileStreamProvider);
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PushPal Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              // GoRouter will handle redirecting to login via authStateChanges
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: userProfileAsyncValue.when(
        data: (userProfile) {
          if (userProfile == null) {
            // This case should ideally be handled by router redirects if user is not logged in
            // or if profile doesn't exist when it should.
            return const Center(
              child: Text('Profile not found. Please try logging in again.'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${userProfile.displayName ?? 'User'}! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (userProfile.fitnessGoal != null &&
                    userProfile.fitnessGoal!.isNotEmpty)
                  Text(
                    'Your current goal: ${userProfile.fitnessGoal}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Find a PushPal'),
                    onPressed: () {
                      context.go('/match');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const Spacer(), // Pushes content to the top, and button to center if Column is expanded
                // TODO: Add more sections like "Your Pals", "Quick Actions" or "Challenges"
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) =>
                Center(child: Text('Error loading your profile: $err')),
      ),
    );
  }
}
