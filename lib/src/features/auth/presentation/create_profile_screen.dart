import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:push_pal/src/features/auth/application/auth_service.dart';
import 'package:push_pal/src/features/auth/application/user_profile_service.dart';
import 'package:push_pal/src/features/auth/domain/user_profile.dart';
import 'package:push_pal/src/widgets/step_progress_indicator.dart'; // Import the progress indicator

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _zipCodeController = TextEditingController();
  DateTime? _selectedDateOfBirth;

  String? _selectedFitnessGoal;
  final List<String> _selectedWorkoutTypes = []; // For multi-select
  String? _selectedGender;
  bool _isLoading = false;
  String? _selectedExperienceLevel;
  String? _selectedCountry;
  DateTime? _selectedDate;

  // Categorized Workout Types
  final Map<String, List<String>> _categorizedWorkoutOptions = {
    "Gym & Strength": [
      "Weightlifting",
      "CrossFit",
      "Postnatal Strength Training",
      "Calisthenics / Bodyweight Training",
      "Functional Training",
    ],
    "Cardio & Endurance": [
      "Running",
      "Cycling",
      "HIIT",
      "Swimming",
      "Sports",
      "Dancing",
    ],
    "Mind, Body & Low Impact": [
      "Yoga",
      "Pilates (modified)",
      "Tai Chi",
      "Chair Yoga",
      "Stretching & Mobility",
      "Meditation Group",
      "Gentle Exercise", // Added from fitness goals, fits here
      "Low-Impact Fitness", // Added from fitness goals, fits here
      "Water Aerobics",
      "Prenatal Yoga",
      "Senior Fitness Class", // Added here
    ],
    "Outdoor & Recreational": [
      "Hiking",
      "Walking",
      "Fishing",
      "Social Walking Group",
    ],
    // "Specialized & Other": [ // If any don't fit neatly
    //   "Senior Fitness Class", // Could also be in Low Impact
    // ]
  };
  // Note: "Senior Fitness Class" can be in "Mind, Body & Low Impact" or a dedicated category if more such items appear.
  // For now, let's place it in Mind, Body & Low Impact for simplicity as it often has those characteristics.
  // We will also add it there.
  // _categorizedWorkoutOptions["Mind, Body & Low Impact"]!.add("Senior Fitness Class"); // Let's add it directly

  final List<String> _fitnessGoalOptions = [
    "Weight Loss",
    "Muscle Gain",
    "Endurance",
    "General Fitness",
    "Improve Flexibility",
    "Stress Relief",
    "Postpartum Recovery",
    "Gentle Exercise",
    "Low-Impact Fitness",
    "Active Aging",
    "Prenatal Fitness",
  ];
  final List<String> _genderOptions = [
    "Male",
    "Female",
    "Non-binary",
    "Other",
    "Prefer not to say",
  ];
  final List<String> _experienceLevelOptions = [
    "Beginner",
    "Intermediate",
    "Advanced",
    "Varies / All Levels",
  ];

  @override
  void dispose() {
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(
        now.year - 13,
        now.month,
        now.day,
      ), // Must be at least 13
      helpText: 'Select your date of birth',
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedFitnessGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your fitness goal.')),
      );
      return;
    }
    if (_selectedWorkoutTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one preferred workout type.'),
        ),
      );
      return;
    }
    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No authenticated user found.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final userProfile = UserProfile(
      uid: currentUser.uid,
      email: currentUser.email,
      displayName: currentUser.displayName,
      profileSetupComplete: false,
      locationZipCode: _zipCodeController.text.trim(),
      fitnessGoal: _selectedFitnessGoal,
      preferredWorkoutTypes: _selectedWorkoutTypes,
      dateOfBirth:
          _selectedDateOfBirth != null
              ? Timestamp.fromDate(_selectedDateOfBirth!)
              : null,
      gender: _selectedGender,
      experienceLevel: _selectedExperienceLevel,
      country: _selectedCountry,
    );

    try {
      await ref.read(userProfileServiceProvider).setUserProfile(userProfile);
      if (mounted) {
        context.go('/set-availability');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDropdown<T>({
    required String labelText, // Changed from hintText for consistency
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

  Widget _buildWorkoutTypeChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Workout Types (Select at least one from relevant categories)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ..._categorizedWorkoutOptions.entries.map((entry) {
          String category = entry.key;
          List<String> workouts = entry.value;
          // Check if any workout in this category is selected to potentially pre-expand the tile
          // bool isCategoryInitiallyExpanded = workouts.any((workout) => _selectedWorkoutTypes.contains(workout));

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ExpansionTile(
              title: Text(
                category,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              // initiallyExpanded: isCategoryInitiallyExpanded, // Optional: expand if a selection exists within
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children:
                      workouts.map((type) {
                        final isSelected = _selectedWorkoutTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedWorkoutTypes.add(type);
                              } else {
                                _selectedWorkoutTypes.remove(type);
                              }
                            });
                          },
                          selectedColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          checkmarkColor: Theme.of(context).primaryColor,
                        );
                      }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Tell us a bit about yourself',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _zipCodeController,
                decoration: const InputDecoration(
                  labelText: 'Zip Code',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please enter your zip code'
                            : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text:
                      _selectedDateOfBirth == null
                          ? ''
                          : DateFormat.yMd().format(_selectedDateOfBirth!),
                ),
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit_calendar_outlined),
                    onPressed: _presentDatePicker,
                  ),
                ),
                onTap: _presentDatePicker,
                validator:
                    (value) =>
                        _selectedDateOfBirth == null
                            ? 'Please select your date of birth'
                            : null,
              ),
              const SizedBox(height: 20),
              _buildDropdown<String>(
                labelText: 'Primary Fitness Goal',
                value: _selectedFitnessGoal,
                items: _fitnessGoalOptions,
                onChanged:
                    (value) => setState(() => _selectedFitnessGoal = value),
                validator:
                    (value) => value == null ? 'Please select a goal' : null,
              ),
              const SizedBox(height: 20),
              _buildWorkoutTypeChips(),
              const SizedBox(height: 20),
              _buildDropdown<String>(
                labelText: 'Gender (Optional)',
                value: _selectedGender,
                items: _genderOptions,
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 20),
              _buildDropdown<String>(
                labelText: 'Experience Level',
                value: _selectedExperienceLevel,
                items: _experienceLevelOptions,
                onChanged:
                    (value) => setState(() => _selectedExperienceLevel = value),
                validator:
                    (value) =>
                        value == null
                            ? 'Please select your experience level'
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Country *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.public),
                ),
                value: _selectedCountry,
                hint: const Text('Select your country'),
                isExpanded: true,
                items:
                    ['USA', 'CAD', 'ESP'].map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountry = newValue;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select your country' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Save & Continue',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
              const SizedBox(height: 24),
              const StepProgressIndicator(
                totalSteps: 3,
                currentStep: 2,
                activeColor: Colors.orange, // Example color
              ),
              const SizedBox(height: 20), // Spacing below indicator
            ],
          ),
        ),
      ),
    );
  }
}
