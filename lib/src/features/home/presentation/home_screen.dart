import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_pal/src/features/auth/application/auth_service.dart';
import 'package:push_pal/src/features/auth/application/user_profile_service.dart';
import 'package:push_pal/src/features/auth/domain/user_profile.dart';
import 'package:go_router/go_router.dart'; // For potential navigation or logout
import 'package:push_pal/src/theme/app_theme.dart'; // Assuming your theme is here

// This HomeScreen is now routed to by GoRouter.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsyncValue = ref.watch(currentUserProfileStreamProvider);
    final authService = ref.watch(authServiceProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, ref, textTheme, colorScheme),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(textTheme, colorScheme),
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, 'Your Next Workouts', () {
                        // TODO: Implement See All Workouts
                        print('See all workouts tapped');
                      }),
                      const SizedBox(height: 8),
                      _buildNextWorkoutItem(
                        context: context,
                        icon: Icons.directions_run,
                        title: '5K Morning Run',
                        details: 'Tomorrow • 7:00 AM • Central Park',
                        participantCount: 2,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 12),
                      _buildNextWorkoutItem(
                        context: context,
                        icon: Icons.fitness_center,
                        title: 'HIIT Session',
                        details: 'Friday • 6:30 PM • GymBox',
                        participantCount: 1,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 24),
                      _buildFindPalCard(context, textTheme, colorScheme),
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, 'Discover Pals', () {
                        // TODO: Implement View All Pals
                        print('View all pals tapped');
                      }),
                    ],
                  ),
                ),
              ),
              _buildDiscoverPalsList(context, colorScheme),
              SliverToBoxAdapter(
                child: const SizedBox(height: 20),
              ), // Bottom padding
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) =>
                Center(child: Text('Error loading your profile: $err')),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    // In a real app, get avatar from a provider:
    // final String? avatarUrl = ref.watch(currentUserAvatarProvider);
    const String? avatarUrl = null; // Placeholder

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
      ),
      sliver: SliverToBoxAdapter(
        child: SafeArea(
          // Ensures content is not obscured by system UI
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'PushPal',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          primaryOrange, // Using primaryOrange from your theme
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.fitness_center, color: primaryOrange, size: 28),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to profile or settings
                  print('Profile avatar tapped');
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300], // Placeholder color
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child:
                      avatarUrl == null
                          ? Icon(
                            Icons.person,
                            color: Colors.grey[600],
                            size: 24,
                          )
                          : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: primaryOrange.withOpacity(0.1), // Light orange background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: primaryOrange.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.emoji_people_outlined, color: primaryOrange, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to push your limits today? Match up and get moving!',
                    style: textTheme.bodyMedium?.copyWith(
                      color: charcoal.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryOrange,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            title.contains("Workouts") ? 'See all' : 'View all',
            style: TextStyle(
              color: primaryOrange.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextWorkoutItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String details,
    required int participantCount,
    required ColorScheme colorScheme,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: primaryOrange.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryOrange.withOpacity(0.15),
              foregroundColor: primaryOrange,
              child: Icon(icon, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Placeholder for participant avatars
                Row(
                  children: List.generate(
                    participantCount > 2
                        ? 2
                        : participantCount, // Show max 2 avatars + count
                    (index) => Align(
                      widthFactor: 0.7,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors
                            .accents[index % Colors.accents.length]
                            .withOpacity(0.5),
                        child: Icon(
                          Icons.person_outline,
                          size: 12,
                          color: appWhite,
                        ),
                      ),
                    ),
                  )..add(
                    participantCount > 2
                        ? Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            '+${participantCount - 2}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: primaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${participantCount} pal${participantCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: primaryOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFindPalCard(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: primaryOrange.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: primaryOrange.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Find a Workout Pal',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryOrange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse matches tailored to your fitness goals and availability.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: charcoal.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Find Matches
                print('Find Matches button tapped');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Find Matches',
                style: textTheme.labelLarge?.copyWith(
                  color: appWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverPalsList(BuildContext context, ColorScheme colorScheme) {
    // Placeholder data
    final List<Map<String, dynamic>> pals = [
      {
        'name': 'Sara',
        'activity': 'Yoga',
        'icon': Icons.self_improvement,
        'avatarUrl': null /* Placeholder */,
      },
      {
        'name': 'David',
        'activity': 'Cycling',
        'icon': Icons.directions_bike,
        'avatarUrl': null /* Placeholder */,
      },
      {
        'name': 'Ava',
        'activity': 'Pilates',
        'icon': Icons.accessibility_new,
        'avatarUrl': null /* Placeholder */,
      },
      {
        'name': 'Mike',
        'activity': 'Running',
        'icon': Icons.directions_run,
        'avatarUrl': null /* Placeholder */,
      },
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 180, // Adjust height as needed
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: pals.length,
          itemBuilder: (context, index) {
            final pal = pals[index];
            return _buildDiscoverPalCard(
              context,
              pal['name'] as String,
              pal['activity'] as String,
              pal['icon'] as IconData,
              pal['avatarUrl'] as String?,
              colorScheme,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDiscoverPalCard(
    BuildContext context,
    String name,
    String activity,
    IconData activityIcon,
    String? avatarUrl,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 130, // Adjust width as needed
      margin: const EdgeInsets.only(right: 12.0, bottom: 4.0, top: 4.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: primaryOrange.withOpacity(0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child:
                    avatarUrl == null
                        ? Icon(Icons.person, color: Colors.grey[600], size: 30)
                        : null,
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 4),
                  Icon(activityIcon, size: 14, color: primaryOrange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TODO:
// 1. Replace placeholder currentUserAvatarProvider with actual user data.
// 2. Implement navigation for "See all", "View all", profile avatar, and "Find Matches".
// 3. Populate "Next Workouts" and "Discover Pals" with real data.
// 4. Refine styling and use actual user avatars for pals.
// 5. Integrate with your existing app routing if this screen needs to be navigated to.
