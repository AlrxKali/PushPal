import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_pal/src/features/auth/domain/user_profile.dart';
import 'package:push_pal/src/features/auth/application/auth_service.dart';

class UserProfileService {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'userProfiles';

  UserProfileService(this._firestore);

  CollectionReference<UserProfile> get _userProfilesRef => _firestore
      .collection(_collectionPath)
      .withConverter<UserProfile>(
        fromFirestore:
            (snapshot, _) => UserProfile.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (profile, _) => profile.toMap(),
      );

  // Create or update a user profile
  // Using set with merge: true will create if it doesn't exist, or update if it does.
  Future<void> setUserProfile(UserProfile userProfile) async {
    try {
      // Ensure updatedAt is set before saving
      // profileSetupComplete will be taken from the passed userProfile object.
      final profileToSave = userProfile.copyWith(
        updatedAt: Timestamp.now(),
        // profileSetupComplete: true, // REVERTED: Respect the incoming userProfile's value
        // If createdAt is null (e.g. new profile), toMap will use FieldValue.serverTimestamp()
        // If it's an update, existing createdAt should be preserved by copyWith if not null.
        createdAt: userProfile.createdAt,
      );
      await _userProfilesRef
          .doc(userProfile.uid)
          .set(profileToSave, SetOptions(merge: true));
      print(
        'UserProfile for ${userProfile.uid} saved/updated. ProfileSetupComplete: ${profileToSave.profileSetupComplete}',
      );
    } catch (e) {
      print('Error saving user profile: ${e.toString()}');
      // Consider re-throwing a custom exception for the UI to handle
      throw Exception('Failed to save user profile.');
    }
  }

  // Get a user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final docSnapshot = await _userProfilesRef.doc(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print('Error fetching user profile for $uid: ${e.toString()}');
      return null;
    }
  }

  // Stream a user profile (useful for real-time updates)
  Stream<UserProfile?> userProfileStream(String uid) {
    try {
      return _userProfilesRef.doc(uid).snapshots().map((snapshot) {
        if (snapshot.exists) {
          return snapshot.data();
        }
        return null;
      });
    } catch (e) {
      print('Error streaming user profile for $uid: ${e.toString()}');
      return Stream.value(null); // Or Stream.error(e)
    }
  }
}

// Provider for FirebaseFirestore instance
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider for UserProfileService
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return UserProfileService(firestore);
});

// Provider to get the current user's profile data as a stream
// This will be key for checking if profileSetupComplete is true
final currentUserProfileStreamProvider = StreamProvider.autoDispose<
  UserProfile?
>((ref) {
  // Directly watch the authStateChangesProvider
  final authState = ref.watch(authStateChangesProvider);

  return authState.when(
    data: (user) {
      if (user != null) {
        // User is logged in, get their profile stream
        final userProfileService = ref.read(
          userProfileServiceProvider,
        ); // Use read as this part doesn't need to re-trigger on UserProfileService changes itself
        print(
          '[currentUserProfileStreamProvider] AuthState data: Logged in as ${user.uid}. Fetching profile.',
        );
        return userProfileService.userProfileStream(user.uid);
      } else {
        // User is null (logged out or no user)
        print(
          '[currentUserProfileStreamProvider] AuthState data: User is null.',
        );
        return Stream.value(null);
      }
    },
    loading: () {
      // Auth state is loading
      print('[currentUserProfileStreamProvider] AuthState loading.');
      return Stream.value(null); // Or an empty stream: Stream.empty()
    },
    error: (error, stackTrace) {
      // Error in auth state
      print('[currentUserProfileStreamProvider] AuthState error: $error');
      return Stream.error(error, stackTrace);
    },
  );
});

// Provider to get the current user's profile data as a future (one-time fetch)
final currentUserProfileFutureProvider =
    FutureProvider.autoDispose<UserProfile?>((ref) async {
      final authService = ref.watch(authServiceProvider);
      final user = authService.getCurrentUser();
      if (user != null) {
        final userProfileService = ref.watch(userProfileServiceProvider);
        return userProfileService.getUserProfile(user.uid);
      }
      return null;
    });
