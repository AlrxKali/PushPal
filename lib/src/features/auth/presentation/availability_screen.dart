import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:push_pal/src/features/auth/application/user_profile_service.dart';
import 'package:push_pal/src/features/auth/domain/user_profile.dart';
import 'package:push_pal/src/widgets/step_progress_indicator.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  // Map to store selected availability: Key = workoutType, Value = List of selected time slots
  Map<String, List<String>> _selectedAvailability = {};
  bool _isLoading = false;

  // Available time slots
  final List<String> _timeSlotOptions = [
    "Morning (5AM-12PM)",
    "Afternoon (1PM-7PM)",
    "Evening (8PM-12AM)",
    "Weekends",
  ];

  @override
  void initState() {
    super.initState();
    // Initialize _selectedAvailability based on current profile if needed, or with empty lists
    final userProfile = ref.read(currentUserProfileStreamProvider).valueOrNull;
    if (userProfile?.preferredWorkoutTypes != null) {
      for (var workoutType in userProfile!.preferredWorkoutTypes!) {
        // Initialize with existing values if they exist, otherwise empty list
        _selectedAvailability[workoutType] = List<String>.from(
          userProfile.workoutAvailability?[workoutType] ?? [],
        );
      }
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isLoading = true);
    final userProfile = ref.read(currentUserProfileStreamProvider).valueOrNull;

    if (userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not load user profile.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Validate that at least one time slot is selected for each preferred workout type
    if (userProfile.preferredWorkoutTypes != null) {
      for (var workoutType in userProfile.preferredWorkoutTypes!) {
        if (_selectedAvailability[workoutType] == null ||
            _selectedAvailability[workoutType]!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please select at least one time slot for $workoutType.',
              ),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      }
    }

    final updatedProfile = userProfile.copyWith(
      workoutAvailability: _selectedAvailability,
      profileSetupComplete: true, // FINAL STEP!
    );

    try {
      await ref.read(userProfileServiceProvider).setUserProfile(updatedProfile);
      // GoRouter will handle redirect to '/' because profileSetupComplete is now true
      // No explicit context.go('/') needed here if router is set up correctly.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save availability: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsyncValue = ref.watch(currentUserProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Availability'),
        // TODO: Add progress indicator here or at the bottom
      ),
      body: userProfileAsyncValue.when(
        data: (userProfile) {
          if (userProfile == null ||
              userProfile.preferredWorkoutTypes == null ||
              userProfile.preferredWorkoutTypes!.isEmpty) {
            return const Center(
              child: Text(
                'Please select your preferred workout types first on the profile screen.',
              ),
            );
          }
          // TODO: Build UI for selecting availability for each workout type
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: userProfile.preferredWorkoutTypes!.length,
                    itemBuilder: (context, index) {
                      final workoutType =
                          userProfile.preferredWorkoutTypes![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workoutType,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              // Add checkboxes for Morning, Afternoon, Evening, Weekends
                              ..._timeSlotOptions.map((slot) {
                                bool isSelected =
                                    _selectedAvailability[workoutType]
                                        ?.contains(slot) ??
                                    false;
                                return CheckboxListTile(
                                  title: Text(slot),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _selectedAvailability.putIfAbsent(
                                        workoutType,
                                        () => [],
                                      );
                                      if (value == true) {
                                        _selectedAvailability[workoutType]!.add(
                                          slot,
                                        );
                                      } else {
                                        _selectedAvailability[workoutType]!
                                            .remove(slot);
                                      }
                                    });
                                  },
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveAvailability,
                  child: const Text('Save & Continue'),
                ),
                const SizedBox(height: 24),
                const StepProgressIndicator(
                  totalSteps: 3,
                  currentStep: 3,
                  activeColor: Colors.orange, // Example color
                ),
                const SizedBox(height: 20), // Spacing below indicator
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(child: Text('Error loading profile: $err')),
      ),
    );
  }
}
