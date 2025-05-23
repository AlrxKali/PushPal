import 'dart:io'; // For File
import 'dart:typed_data'; // Added for Uint8List
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // For ImagePicker
import 'package:push_pal/src/features/auth/application/user_profile_service.dart';
import 'package:push_pal/src/features/auth/domain/user_profile.dart';
import 'package:push_pal/src/features/auth/application/auth_service.dart'; // For current user
import 'package:image_cropper/image_cropper.dart';

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

  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes; // Added for image preview on web
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Image',
              doneButtonTitle: 'Done',
              cancelButtonTitle: 'Cancel',
              minimumAspectRatio:
                  1.0, // Ensures user can crop to at least a square
            ),
            WebUiSettings(
              context: context, // Essential for web dialogs/modals
              // Keeping WebUiSettings minimal as specific parameters for v9 can vary
              // and might require more in-depth CSS or custom JS interop for advanced styling.
              // The global `aspectRatio` parameter below should guide the default crop area.
            ),
          ],
          aspectRatio: const CropAspectRatio(
            ratioX: 1.0,
            ratioY: 1.0,
          ), // Default to square
          compressQuality: 75,
          maxWidth: 600,
          maxHeight: 600,
        );

        if (croppedFile != null) {
          final XFile finalImageFile = XFile(croppedFile.path);
          final bytes = await finalImageFile.readAsBytes();
          setState(() {
            _selectedImageFile = finalImageFile;
            _selectedImageBytes = bytes;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
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
    print('[_saveProfile] Attempting to save profile...');
    if (!(_formKey.currentState?.validate() ?? false)) {
      print('[_saveProfile] Form validation failed.');
      return;
    }
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

    setState(() {
      print('[_saveProfile] Setting _isLoading = true');
      _isLoading = true;
    });

    final currentProfile =
        ref.read(currentUserProfileStreamProvider).valueOrNull;
    if (currentProfile == null) {
      print('[_saveProfile] Error: currentProfile is null.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: Could not load current profile. Please try again.',
            ),
          ),
        );
        setState(() {
          print(
            '[_saveProfile] currentProfile null path: Setting _isLoading = false',
          );
          _isLoading = false;
        });
      }
      return;
    }
    print('[_saveProfile] currentProfile loaded: ${currentProfile.uid}');

    String? newProfilePictureUrl = currentProfile.profilePictureUrl;
    if (_selectedImageFile != null) {
      print('[_saveProfile] Attempting to upload profile picture...');
      try {
        final currentUserUid =
            ref.read(authServiceProvider).getCurrentUser()?.uid;
        if (currentUserUid == null) {
          print(
            '[_saveProfile] Error: User not authenticated for image upload.',
          );
          throw Exception('User not authenticated, cannot upload image.');
        }
        print('[_saveProfile] Uploading image for UID: $currentUserUid');
        newProfilePictureUrl = await ref
            .read(userProfileServiceProvider)
            .uploadProfilePicture(currentUserUid, _selectedImageFile!);
        print(
          '[_saveProfile] Image uploaded successfully: $newProfilePictureUrl',
        );
      } catch (e) {
        print(
          '[_saveProfile] Error uploading profile picture: ${e.toString()}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload profile picture: ${e.toString()}',
              ),
            ),
          );
          setState(() {
            print(
              '[_saveProfile] Image upload error path: Setting _isLoading = false',
            );
            _isLoading = false;
          });
        }
        return; // Stop if image upload fails
      }
    } else {
      print('[_saveProfile] No new image selected for upload.');
    }

    // Determine if zip code or country has changed to reset placeName and admin1Name
    String? newPlaceName = currentProfile.placeName;
    String? newAdmin1Name = currentProfile.admin1Name;
    final newZipCode = _zipCodeController.text.trim();
    final newCountry = _selectedCountry;
    if (newZipCode != currentProfile.locationZipCode ||
        newCountry != currentProfile.country) {
      print(
        '[_saveProfile] Zip or Country changed. Clearing placeName/admin1Name.',
      );
      newPlaceName = null;
      newAdmin1Name = null;
    }

    final updatedProfile = currentProfile.copyWith(
      displayName: _displayNameController.text.trim(),
      aboutMe: _aboutMeController.text.trim(),
      profilePictureUrl: newProfilePictureUrl,
      locationZipCode: newZipCode,
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
      country: newCountry,
      placeName: newPlaceName,
      admin1Name: newAdmin1Name,
      // profileSetupComplete is not changed here, it's managed elsewhere (e.g. after availability setup)
    );
    print(
      '[_saveProfile] Profile object to save: ${updatedProfile.toMap()} (timestamps will be handled by service)',
    );

    try {
      print('[_saveProfile] Calling setUserProfile...');
      await ref.read(userProfileServiceProvider).setUserProfile(updatedProfile);
      print('[_saveProfile] setUserProfile successful.');
      if (mounted) {
        setState(() {
          print(
            '[_saveProfile] Save success path: Setting _isLoading = false BEFORE pop.',
          );
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        print('[_saveProfile] Popping screen.');
        context.pop();
      }
    } catch (e) {
      print(
        '[_saveProfile] Error saving profile to Firestore: ${e.toString()}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: ${e.toString()}')),
        );
        setState(() {
          print(
            '[_saveProfile] Firestore save error path: Setting _isLoading = false',
          );
          _isLoading = false;
        });
      }
    } finally {
      print(
        '[_saveProfile] Entering finally block. _isLoading is $_isLoading (should be false if successful save path was taken before pop)',
      );
      // This finally is mainly a safeguard for unexpected exits or if an error happened before a dedicated setState for isLoading=false
      if (mounted && _isLoading) {
        print(
          '[_saveProfile] Finally block: Setting _isLoading = false as a safeguard because it was still true.',
        );
        setState(() => _isLoading = false);
      }
      print('[_saveProfile] Exiting _saveProfile method.');
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
    final userProfile = ref.watch(currentUserProfileStreamProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _selectedImageBytes != null
                              ? MemoryImage(
                                _selectedImageBytes!,
                              ) // Use MemoryImage for new local preview
                              : (userProfile?.profilePictureUrl != null &&
                                  userProfile!.profilePictureUrl!.isNotEmpty)
                              ? NetworkImage(userProfile.profilePictureUrl!)
                              : null as ImageProvider?,
                      child:
                          (_selectedImageBytes == null &&
                                  (userProfile?.profilePictureUrl == null ||
                                      userProfile!.profilePictureUrl!.isEmpty))
                              ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[600],
                              )
                              : null,
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
