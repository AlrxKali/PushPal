import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final bool profileSetupComplete;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? locationZipCode;
  final String? fitnessGoal; // e.g., "weightLoss", "muscleGain", "endurance"
  final List<String>? preferredWorkoutTypes; // Changed to List<String>
  final Timestamp? dateOfBirth; // Added dateOfBirth
  final String? gender; // e.g., "male", "female", "other", "preferNotToSay"
  final Map<String, List<String>>?
  workoutAvailability; // Key: workoutType, Value: list of time slots
  final String? durationPreference; // e.g., "30 mins", "1 hour"
  final String? intensityPreference; // e.g., "Low", "Moderate", "High"
  final String? preferredBuddyGender; // e.g., "Male", "Female", "No Preference"

  UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.profileSetupComplete = false,
    this.createdAt,
    this.updatedAt,
    this.locationZipCode,
    this.fitnessGoal,
    this.preferredWorkoutTypes,
    this.dateOfBirth,
    this.gender,
    this.workoutAvailability,
    this.durationPreference,
    this.intensityPreference,
    this.preferredBuddyGender,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? profileSetupComplete,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? locationZipCode,
    String? fitnessGoal,
    List<String>? preferredWorkoutTypes,
    Timestamp? dateOfBirth, // Added dateOfBirth
    String? gender,
    Map<String, List<String>>? workoutAvailability,
    String? durationPreference,
    String? intensityPreference,
    String? preferredBuddyGender,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileSetupComplete: profileSetupComplete ?? this.profileSetupComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      locationZipCode: locationZipCode ?? this.locationZipCode,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      preferredWorkoutTypes:
          preferredWorkoutTypes ?? this.preferredWorkoutTypes,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      workoutAvailability: workoutAvailability ?? this.workoutAvailability,
      durationPreference: durationPreference ?? this.durationPreference,
      intensityPreference: intensityPreference ?? this.intensityPreference,
      preferredBuddyGender: preferredBuddyGender ?? this.preferredBuddyGender,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      'profileSetupComplete': profileSetupComplete,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(), // Set on create
      'updatedAt':
          updatedAt ?? FieldValue.serverTimestamp(), // Set on create/update
      if (locationZipCode != null) 'locationZipCode': locationZipCode,
      if (fitnessGoal != null) 'fitnessGoal': fitnessGoal,
      if (preferredWorkoutTypes != null && preferredWorkoutTypes!.isNotEmpty)
        'preferredWorkoutTypes': preferredWorkoutTypes,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (workoutAvailability != null)
        'workoutAvailability': workoutAvailability,
      if (durationPreference != null) 'durationPreference': durationPreference,
      if (intensityPreference != null)
        'intensityPreference': intensityPreference,
      if (preferredBuddyGender != null)
        'preferredBuddyGender': preferredBuddyGender,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String documentId) {
    return UserProfile(
      uid: documentId, // Or map['uid'] if you store uid also as a field
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      profileSetupComplete: map['profileSetupComplete'] as bool? ?? false,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
      locationZipCode: map['locationZipCode'] as String?,
      fitnessGoal: map['fitnessGoal'] as String?,
      preferredWorkoutTypes:
          map['preferredWorkoutTypes'] != null
              ? List<String>.from(map['preferredWorkoutTypes'] as List<dynamic>)
              : null, // Changed to List<String>
      dateOfBirth: map['dateOfBirth'] as Timestamp?, // Added dateOfBirth
      gender: map['gender'] as String?,
      workoutAvailability:
          map['workoutAvailability'] != null
              ? Map<String, List<String>>.from(
                (map['workoutAvailability'] as Map<String, dynamic>).map(
                  (key, value) =>
                      MapEntry(key, List<String>.from(value as List<dynamic>)),
                ),
              )
              : null,
      durationPreference: map['durationPreference'] as String?,
      intensityPreference: map['intensityPreference'] as String?,
      preferredBuddyGender: map['preferredBuddyGender'] as String?,
    );
  }
}
