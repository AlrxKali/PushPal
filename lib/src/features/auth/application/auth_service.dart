import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Custom Exception for Auth errors to be caught by UI
class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => message;
}

// TODO: Implement Firebase Authentication logic here

class AuthService {
  AuthService(this._firebaseAuth);
  final FirebaseAuth _firebaseAuth;

  // Example: Stream to listen to auth state changes
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? getCurrentUser() => _firebaseAuth.currentUser;

  // Example: Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName, // Optional: to set user's display name
  }) async {
    print('[AuthService] Attempting signUp: $email'); // DEBUG PRINT
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('[AuthService] SignUp successful for: $email'); // DEBUG PRINT
      if (userCredential.user != null && displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload(); // Reload to get updated user info
        print('[AuthService] DisplayName updated and user reloaded for: $email'); // DEBUG PRINT
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('[AuthService] FirebaseAuthException during signUp: ${e.code} - ${e.message}'); // DEBUG PRINT
      if (e.code == 'weak-password') {
        throw AuthServiceException('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthServiceException('An account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        throw AuthServiceException('The email address is not valid.');
      }
      throw AuthServiceException(e.message ?? 'An unknown error occurred during sign up.');
    } catch (e) {
      print('[AuthService] Generic Exception during signUp: ${e.toString()}'); // DEBUG PRINT
      throw AuthServiceException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Example: Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    print('[AuthService] Attempting signIn: $email'); // DEBUG PRINT
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('[AuthService] SignIn successful for: $email'); // DEBUG PRINT
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('[AuthService] FirebaseAuthException during signIn: ${e.code} - ${e.message}'); // DEBUG PRINT
      if (e.code == 'user-not-found') {
        throw AuthServiceException('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw AuthServiceException('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        throw AuthServiceException('The email address is not valid.');
      } else if (e.code == 'invalid-credential') {
         throw AuthServiceException('Invalid credentials. Please check your email and password.');
      }
      throw AuthServiceException(e.message ?? 'An unknown error occurred during sign in.');
    } catch (e) {
      print('[AuthService] Generic Exception during signIn: ${e.toString()}'); // DEBUG PRINT
      throw AuthServiceException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Example: Sign out
  Future<void> signOut() async {
    print('[AuthService] Attempting signOut'); // DEBUG PRINT
    try {
      await _firebaseAuth.signOut();
      print('[AuthService] SignOut successful'); // DEBUG PRINT
    } catch (e) {
      print('[AuthService] Error signing out: ${e.toString()}'); // DEBUG PRINT
      throw AuthServiceException('Error signing out. Please try again.');
    }
  }
}

// Riverpod provider for the FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Riverpod provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return AuthService(firebaseAuth);
});

// Riverpod stream provider for auth state changes
final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) { // autoDispose is good practice
  return ref.watch(authServiceProvider).authStateChanges();
});

// Provider to get the current user easily
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).getCurrentUser();
}); 