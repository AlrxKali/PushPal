import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:push_pal/src/features/auth/application/user_profile_service.dart';
import 'package:push_pal/src/features/auth/domain/user_profile.dart';
import 'package:push_pal/src/features/auth/application/auth_service.dart'; // For current user

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _aboutMeController;
  late TextEditingController _zipCodeController;
  DateTime? _selectedDateOfBirth;
  String? _selectedFitnessGoal;
  List<String> _selectedWorkoutTypes = [];
  String? _selectedGender;
  String? _selectedExperienceLevel;
  String? _selectedDurationPreference;
  String? _selectedIntensityPreference;
  String? _selectedBuddyGender;
  String? _selectedCountry;
  bool _isLoading = false;

  // Options (can be shared or redefined here, consider a constants file later)
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
      "Gentle Exercise",
      "Low-Impact Fitness",
      "Water Aerobics",
      "Prenatal Yoga",
      "Senior Fitness Class",
    ],
    "Outdoor & Recreational": [
      "Hiking",
      "Walking",
      "Fishing",
      "Social Walking Group",
    ],
  };
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
    _displayNameController = TextEditingController(
      text: userProfile?.displayName ?? '',
    );
    _aboutMeController = TextEditingController(
      text: userProfile?.aboutMe ?? '',
    );
    _zipCodeController = TextEditingController(
      text: userProfile?.locationZipCode ?? '',
    );
    _selectedDateOfBirth = userProfile?.dateOfBirth?.toDate();
    _selectedFitnessGoal = userProfile?.fitnessGoal;
    _selectedWorkoutTypes = List<String>.from(
      userProfile?.preferredWorkoutTypes ?? [],
    );
    _selectedGender = userProfile?.gender;
    _selectedExperienceLevel = userProfile?.experienceLevel;
    _selectedDurationPreference = userProfile?.durationPreference;
    _selectedIntensityPreference = userProfile?.intensityPreference;
    _selectedBuddyGender = userProfile?.preferredBuddyGender;
    _selectedCountry = userProfile?.country;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _aboutMeController.dispose();
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
      lastDate: DateTime(now.year - 13, now.month, now.day),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Add validation for any new required fields here (e.g., DOB, fitness goal if they become non-optional in edit)
    if (_selectedFitnessGoal == null) {
      /* show snackbar */
      return;
    }
    if (_selectedWorkoutTypes.isEmpty) {
      /* show snackbar */
      return;
    }
    if (_selectedDateOfBirth == null) {
      /* show snackbar */
      return;
    }
    if (_selectedDurationPreference == null) {
      /* show snackbar for duration */
      return;
    }
    if (_selectedIntensityPreference == null) {
      /* show snackbar for intensity */
      return;
    }
    // Buddy gender is optional, no validation needed unless specified

    setState(() => _isLoading = true);

    final currentProfile =
        ref.read(currentUserProfileStreamProvider).valueOrNull;
    if (currentProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: Could not load current profile. Please try again.',
            ),
          ),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    // Determine if zip code or country has changed to reset placeName and admin1Name
    String? newPlaceName = currentProfile.placeName;
    String? newAdmin1Name = currentProfile.admin1Name;

    final newZipCode = _zipCodeController.text.trim();
    final newCountry = _selectedCountry;

    if (newZipCode != currentProfile.locationZipCode ||
        newCountry != currentProfile.country) {
      newPlaceName = null;
      newAdmin1Name = null;
    }

    final updatedProfile = currentProfile.copyWith(
      displayName: _displayNameController.text.trim(),
      aboutMe: _aboutMeController.text.trim(),
      locationZipCode: newZipCode, // Use the new zip code
      dateOfBirth:
          _selectedDateOfBirth != null
              ? Timestamp.fromDate(_selectedDateOfBirth!)
              : null,
      fitnessGoal: _selectedFitnessGoal,
      preferredWorkoutTypes: _selectedWorkoutTypes,
      gender: _selectedGender,
      experienceLevel: _selectedExperienceLevel,
      durationPreference: _selectedDurationPreference,
      intensityPreference: _selectedIntensityPreference,
      preferredBuddyGender: _selectedBuddyGender,
      country: newCountry, // Use the new country
      placeName:
          newPlaceName, // Will be null if zip/country changed, otherwise original
      admin1Name:
          newAdmin1Name, // Will be null if zip/country changed, otherwise original
      // profileSetupComplete is not changed here, it's managed elsewhere (e.g. after availability setup)
    );

    try {
      await ref.read(userProfileServiceProvider).setUserProfile(updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      // error handling
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDropdown<T>({
    required String labelText,
    T? value,
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
    // Copied from CreateProfileScreen, adjust if needed
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Workout Types',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ..._categorizedWorkoutOptions.entries.map((entry) {
          String category = entry.key;
          List<String> workouts = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ExpansionTile(
              title: Text(
                category,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
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
                              if (selected)
                                _selectedWorkoutTypes.add(type);
                              else
                                _selectedWorkoutTypes.remove(type);
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
      appBar: AppBar(title: const Text('Edit Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator:
                    (v) => (v == null || v.isEmpty) ? 'Name required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _zipCodeController,
                decoration: const InputDecoration(labelText: 'Zip Code'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator:
                    (v) => (v == null || v.isEmpty) ? 'Zip required' : null,
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
                    (v) => _selectedDateOfBirth == null ? 'DOB required' : null,
              ),
              const SizedBox(height: 20),
              _buildDropdown<String>(
                labelText: 'Primary Fitness Goal',
                value: _selectedFitnessGoal,
                items: _fitnessGoalOptions,
                onChanged: (v) => setState(() => _selectedFitnessGoal = v),
                validator: (v) => v == null ? 'Goal required' : null,
              ),
              const SizedBox(height: 20),
              _buildWorkoutTypeChips(),
              const SizedBox(height: 20),
              _buildDropdown<String>(
                labelText: 'Gender (Optional)',
                value: _selectedGender,
                items: _genderOptions,
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 20),
              _buildDropdown<String>(
                labelText: 'Experience Level',
                value: _selectedExperienceLevel,
                items: _experienceLevelOptions,
                onChanged: (v) => setState(() => _selectedExperienceLevel = v),
                validator: (v) => v == null ? 'Level required' : null,
              ),
              const SizedBox(height: 20),
              _buildDropdown<String>(
                labelText: 'Typical Workout Duration',
                value: _selectedDurationPreference,
                items: _durationOptions,
                onChanged:
                    (v) => setState(() => _selectedDurationPreference = v),
                validator: (v) => v == null ? 'Duration required' : null,
              ),
              const SizedBox(height: 20),
              _buildDropdown<String>(
                labelText: 'Preferred Workout Intensity',
                value: _selectedIntensityPreference,
                items: _intensityOptions,
                onChanged:
                    (v) => setState(() => _selectedIntensityPreference = v),
                validator: (v) => v == null ? 'Intensity required' : null,
              ),
              const SizedBox(height: 20),
              _buildDropdown<String>(
                labelText: 'Preferred Buddy Gender (Optional)',
                value: _selectedBuddyGender,
                items: _buddyGenderOptions,
                onChanged: (v) => setState(() => _selectedBuddyGender = v),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _aboutMeController,
                decoration: const InputDecoration(
                  labelText: 'About Me',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 300,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter your About Me'
                            : null,
              ),
              const SizedBox(height: 16),

              // Country Dropdown
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
                          'Save Changes',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
