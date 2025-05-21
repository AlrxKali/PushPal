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
  Map<String, List<String>> _selectedAvailability = {};
  bool _isLoading = false;
  String? _selectedDurationPreference;
  String? _selectedIntensityPreference;
  String? _selectedBuddyGender;

  final List<String> _timeSlotOptions = [
    "Morning (5AM-12PM)",
    "Afternoon (1PM-7PM)",
    "Evening (8PM-12AM)",
    "Weekends",
  ];

  final List<String> _durationOptions = [
    "Under 30 minutes",
    "30-45 minutes",
    "45-60 minutes",
    "1 hour - 1.5 hours",
    "Over 1.5 hours",
    "Flexible",
  ];

  final List<String> _intensityOptions = [
    "Low (Gentle, easy pace)",
    "Moderate (Noticeable effort, can talk)",
    "High (Vigorous, challenging)",
    "Varies / Flexible",
  ];

  final List<String> _buddyGenderOptions = [
    "Male",
    "Female",
    "Mixed Group / No Preference",
  ];

  @override
  void initState() {
    super.initState();
    final userProfile = ref.read(currentUserProfileStreamProvider).valueOrNull;
    if (userProfile != null) {
      if (userProfile.preferredWorkoutTypes != null) {
        for (var workoutType in userProfile.preferredWorkoutTypes!) {
          _selectedAvailability[workoutType] = List<String>.from(
            userProfile.workoutAvailability?[workoutType] ?? [],
          );
        }
      }
      _selectedDurationPreference = userProfile.durationPreference;
      _selectedIntensityPreference = userProfile.intensityPreference;
      _selectedBuddyGender = userProfile.preferredBuddyGender;
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

    // Validate Duration and Intensity
    if (_selectedDurationPreference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your typical workout duration.'),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    if (_selectedIntensityPreference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your preferred workout intensity.'),
        ),
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
      durationPreference: _selectedDurationPreference,
      intensityPreference: _selectedIntensityPreference,
      preferredBuddyGender: _selectedBuddyGender,
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
                _buildDropdown<String>(
                  context: context,
                  labelText: 'Typical Workout Duration',
                  value: _selectedDurationPreference,
                  items: _durationOptions,
                  onChanged:
                      (value) =>
                          setState(() => _selectedDurationPreference = value),
                  validator:
                      (value) =>
                          value == null
                              ? 'Please select a typical duration'
                              : null,
                ),
                const SizedBox(height: 16),
                _buildDropdown<String>(
                  context: context,
                  labelText: 'Preferred Workout Intensity',
                  value: _selectedIntensityPreference,
                  items: _intensityOptions,
                  onChanged:
                      (value) =>
                          setState(() => _selectedIntensityPreference = value),
                  validator:
                      (value) =>
                          value == null
                              ? 'Please select a preferred intensity'
                              : null,
                ),
                const SizedBox(height: 16),
                _buildDropdown<String>(
                  context: context,
                  labelText: 'Preferred Buddy Gender (Optional)',
                  value: _selectedBuddyGender,
                  items: _buddyGenderOptions,
                  onChanged:
                      (value) => setState(() => _selectedBuddyGender = value),
                ),
                const SizedBox(height: 24),
                Text(
                  "Select available times for your preferred workouts:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
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

// Helper for dropdown, can be moved to a utility file or kept here if not used elsewhere extensively
Widget _buildDropdown<T>({
  required BuildContext context,
  required String labelText,
  required T? value,
  required List<T> items,
  required ValueChanged<T?> onChanged,
  String? Function(T?)? validator,
}) {
  return DropdownButtonFormField<T>(
    value: value,
    decoration: InputDecoration(
      labelText: labelText,
      border: const OutlineInputBorder(),
    ),
    items:
        items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              ),
            )
            .toList(),
    onChanged: onChanged,
    validator: validator,
  );
}
