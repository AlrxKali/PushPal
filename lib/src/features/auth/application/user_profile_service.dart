import 'dart:io'; // For File - though File is not directly used in uploadProfilePicture for web compatibility
import 'dart:typed_data'; // For Uint8List
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'
    as firebase_storage; // For Firebase Storage
import 'package:image_picker/image_picker.dart'; // For XFile
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_pal/src/features/auth/domain/user_profile.dart';
import 'package:push_pal/src/features/auth/application/auth_service.dart';

class UserProfileService {
  final FirebaseFirestore _firestore;
  final firebase_storage.FirebaseStorage
  _storage; // Added FirebaseStorage instance
  static const String _collectionPath = 'userProfiles';

  UserProfileService(this._firestore, this._storage); // Updated constructor

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

  // Updated to take XFile and use putData for web compatibility
  Future<String> uploadProfilePicture(String uid, XFile imageXFile) async {
    print(
      '[UserProfileService - uploadProfilePicture] Method started for UID: $uid, file: ${imageXFile.name}',
    );
    try {
      String originalFileName = imageXFile.name;
      if (originalFileName.trim().isEmpty) {
        print(
          '[UserProfileService - uploadProfilePicture] imageXFile.name was empty, using default.',
        );
        // Try to infer extension from mimeType if name is empty
        String extension = 'jpg'; // Default extension
        if (imageXFile.mimeType != null) {
          if (imageXFile.mimeType == 'image/png')
            extension = 'png';
          else if (imageXFile.mimeType == 'image/gif')
            extension = 'gif';
          // Add more mime types if needed
        }
        originalFileName = 'profile_pic.$extension';
      }

      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$originalFileName';
      print(
        '[UserProfileService - uploadProfilePicture] Generated fileName: $fileName',
      );

      final firebase_storage.Reference ref = _storage.ref(
        'profile_pictures/$uid/$fileName',
      );
      print(
        '[UserProfileService - uploadProfilePicture] Storage reference created: ${ref.fullPath}',
      );

      print(
        '[UserProfileService - uploadProfilePicture] Reading image bytes...',
      );
      final Uint8List imageBytes = await imageXFile.readAsBytes();
      print(
        '[UserProfileService - uploadProfilePicture] Image bytes read, length: ${imageBytes.length}',
      );

      final metadata = firebase_storage.SettableMetadata(
        contentType: imageXFile.mimeType ?? 'image/jpeg',
      );
      print(
        '[UserProfileService - uploadProfilePicture] Metadata created, contentType: ${metadata.contentType}',
      );

      print(
        '[UserProfileService - uploadProfilePicture] Attempting to putData to Firebase Storage...',
      );
      final firebase_storage.UploadTask uploadTask = ref.putData(
        imageBytes,
        metadata,
      );

      // You can listen to task events for more detailed progress/error handling if needed
      // uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      //   print('Task state: ${snapshot.state}'); // current state of the upload
      //   print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      // }, onError: (e) {
      //   print('[UserProfileService - uploadProfilePicture] Error during uploadTask stream: $e');
      // });

      print(
        '[UserProfileService - uploadProfilePicture] UploadTask created. Awaiting completion of upload...',
      );
      final firebase_storage.TaskSnapshot snapshot =
          await uploadTask; // This is where it might hang
      print(
        '[UserProfileService - uploadProfilePicture] UploadTask completed. State: ${snapshot.state}',
      );

      print(
        '[UserProfileService - uploadProfilePicture] Getting download URL...',
      );
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print(
        '[UserProfileService - uploadProfilePicture] Download URL received: $downloadUrl',
      );

      return downloadUrl;
    } on firebase_storage.FirebaseException catch (e) {
      print(
        '[UserProfileService - uploadProfilePicture] Firebase Storage Exception: ${e.code} - ${e.message}',
      );
      print(e.stackTrace);
      throw Exception('Failed to upload profile picture: ${e.message}');
    } catch (e, s) {
      print(
        '[UserProfileService - uploadProfilePicture] Generic error: ${e.toString()}',
      );
      print(s); // Print stack trace for generic errors too
      throw Exception('An unexpected error occurred during image upload.');
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

// Provider for FirebaseStorage instance
final firebaseStorageProvider = Provider<firebase_storage.FirebaseStorage>((
  ref,
) {
  return firebase_storage.FirebaseStorage.instance;
});

// Provider for UserProfileService
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final storage = ref.watch(firebaseStorageProvider); // Added storage
  return UserProfileService(firestore, storage); // Updated constructor call
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
