import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_pal/src/features/auth/application/user_profile_service.dart';
import 'package:push_pal/src/features/auth/domain/user_profile.dart'; // Ensure this is imported
import 'package:push_pal/src/theme/app_theme.dart'; // For colors if needed
import 'package:go_router/go_router.dart';

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  Widget _buildUserInfoCard(BuildContext context, UserProfile userProfile) {
    List<String> tags = [];
    if (userProfile.experienceLevel != null &&
        userProfile.experienceLevel!.isNotEmpty) {
      tags.add(userProfile.experienceLevel!);
    }
    if (userProfile.fitnessGoal != null &&
        userProfile.fitnessGoal!.isNotEmpty) {
      tags.add(userProfile.fitnessGoal!);
    }
    if (userProfile.intensityPreference != null &&
        userProfile.intensityPreference!.isNotEmpty) {
      String intensityTag = userProfile.intensityPreference!;
      if (intensityTag.contains("(")) {
        // Shorten if it has a description in parens
        intensityTag =
            intensityTag.substring(0, intensityTag.indexOf("(")).trim();
      }
      if (tags.length < 3) {
        // Add intensity only if we have space for it (e.g., max 3 tags)
        tags.add(intensityTag);
      }
    }
    tags = tags.toSet().toList(); // Ensure unique and limit if necessary
    if (tags.length > 3) tags = tags.take(3).toList(); // Max 3 tags

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundImage:
                        userProfile.profilePictureUrl != null
                            ? NetworkImage(userProfile.profilePictureUrl!)
                            : null,
                    child:
                        userProfile.profilePictureUrl == null
                            ? const Icon(Icons.person, size: 56)
                            : null,
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement profile picture change
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Change picture coming soon!'),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                userProfile.displayName ?? 'PushPal User',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  children: <TextSpan>[
                    TextSpan(
                      text: userProfile.locationZipCode ?? 'Zip not set',
                    ),
                    if (userProfile.country != null &&
                        userProfile.country!.isNotEmpty)
                      TextSpan(
                        text: ' - ${userProfile.country}',
                      ), // Display country next to zip
                  ],
                ),
              ),
            ),
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children:
                      tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.grey[200],
                            ),
                          )
                          .toList(),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/edit-profile'); // Navigate to edit profile screen
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  36,
                ), // Make button wider
              ),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutMeCard(BuildContext context, UserProfile userProfile) {
    if (userProfile.aboutMe == null || userProfile.aboutMe!.isEmpty) {
      return const SizedBox.shrink(); // Don't show card if no about me
    }
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userProfile.aboutMe!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutPreferencesCard(
    BuildContext context,
    UserProfile userProfile,
  ) {
    if (userProfile.preferredWorkoutTypes == null ||
        userProfile.preferredWorkoutTypes!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children:
                  userProfile.preferredWorkoutTypes!
                      .map(
                        (type) => Chip(
                          label: Text(type),
                          backgroundColor: Colors.grey[200],
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsCard(BuildContext context, UserProfile userProfile) {
    if (userProfile.fitnessGoal == null || userProfile.fitnessGoal!.isEmpty) {
      return const SizedBox.shrink();
    }
    // Assuming fitnessGoal is a single string, could be a list later
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Goals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: primaryOrange,
              ),
              title: Text(
                userProfile.fitnessGoal!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              dense: true,
            ),
            // If goals were a list, you'd map over them here
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsyncValue = ref.watch(currentUserProfileStreamProvider);

    return Scaffold(
      // AppBar is handled by MainAppShell, or could be custom here if needed
      // For the design, we'll add a custom header row in the body
      backgroundColor:
          Colors.grey[100], // Light background for contrast with cards
      body: userProfileAsyncValue.when(
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(child: Text('Profile not available.'));
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Custom Header part
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PushPal',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, size: 28),
                          onPressed: () {
                            // TODO: Navigate to a dedicated settings screen (not the tab)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Full Settings screen coming soon!',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildUserInfoCard(context, userProfile),
                    _buildAboutMeCard(context, userProfile),
                    _buildWorkoutPreferencesCard(context, userProfile),
                    _buildGoalsCard(context, userProfile),
                    // TODO: Add Social Links Card if desired
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: ${e.toString()}')),
      ),
    );
  }
}
