import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_app/features/auth/domain/entities/user_profile.dart';
import 'package:workout_app/features/auth/domain/services/auth_service.dart';
import 'package:workout_app/features/auth/domain/services/user_profile_service.dart';
import 'package:workout_app/features/auth/presentation/providers/current_user_profile_stream_provider.dart';
import 'package:workout_app/features/auth/presentation/providers/go_router_provider.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _datePickerController = TextEditingController();
  List<String> _selectedWorkoutTypes = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _availableWorkoutTypes = [
    'Cardio', 'Strength Training', 'Yoga', 'Pilates', 'CrossFit', 'HIIT', 'Zumba', 'Cycling', 'Running', 'Swimming', 'Dance', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _datePickerController.text = "${_selectedDate.toLocal()}".split(' ')[0];
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _datePickerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _datePickerController.text = "${_selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
        if (_selectedWorkoutTypes.isEmpty) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select at least one workout type.')),
            );
        }
        return;
    }
    if (_selectedWorkoutTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one workout type before saving.')),
        );
        return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No authenticated user found. Please log in again.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final userProfile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        fullName: _fullNameController.text,
        dateOfBirth: Timestamp.fromDate(_selectedDate),
        preferredWorkoutTypes: _selectedWorkoutTypes,
        profileSetupComplete: true,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await ref.read(userProfileServiceProvider).setUserProfile(userProfile);
      print('[CreateProfileScreen._saveProfile] setUserProfile complete.');
      
      ref.invalidate(currentUserProfileStreamProvider);
      print('[CreateProfileScreen._saveProfile] currentUserProfileStreamProvider invalidated.');
      
      await Future.delayed(const Duration(milliseconds: 300));
      print('[CreateProfileScreen._saveProfile] After 300ms delay.');

      if (mounted) {
        final currentProfileAsyncValue = ref.read(currentUserProfileStreamProvider);
        final UserProfile? userProfileFromRead = currentProfileAsyncValue.valueOrNull as UserProfile?;
        final bool profileCompleteFromRead = userProfileFromRead?.profileSetupComplete ?? false;
        
        print('[CreateProfileScreen._saveProfile] Just before context.go(\'/\'):');
        print('[CreateProfileScreen._saveProfile]   Profile AsyncValue from ref.read: $currentProfileAsyncValue');
        print('[CreateProfileScreen._saveProfile]   Profile from ref.read: ${userProfileFromRead?.toMap()}');
        print('[CreateProfileScreen._saveProfile]   ProfileComplete from ref.read: $profileCompleteFromRead');
        
        print('[CreateProfileScreen._saveProfile] Calling context.go(\'/\').');
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _datePickerController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: 'Select your date of birth',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your date of birth';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Preferred Workout Types:', style: TextStyle(fontSize: 16)),
                    Wrap(
                      spacing: 8.0,
                      children: _availableWorkoutTypes.map((type) {
                        return FilterChip(
                          label: Text(type),
                          selected: _selectedWorkoutTypes.contains(type),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedWorkoutTypes.add(type);
                              } else {
                                _selectedWorkoutTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (_selectedWorkoutTypes.isEmpty && _formKey.currentState?.validate() == false)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please select at least one workout type',
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save & Continue'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 