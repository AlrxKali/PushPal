import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Implement Firebase Authentication logic here

class AuthService {
  AuthService(this._firebaseAuth);
  final FirebaseAuth _firebaseAuth;

  // Example: Stream to listen to auth state changes
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  // Example: Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // try {
    //   return await _firebaseAuth.createUserWithEmailAndPassword(
    //     email: email,
    //     password: password,
    //   );
    // } on FirebaseAuthException catch (e) {
    //   // Handle errors (e.g., email-already-in-use, weak-password)
    //   print(e.message);
    //   return null;
    // }
    return null; // Placeholder
  }

  // Example: Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // try {
    //   return await _firebaseAuth.signInWithEmailAndPassword(
    //     email: email,
    //     password: password,
    //   );
    // } on FirebaseAuthException catch (e) {
    //   // Handle errors (e.g., user-not-found, wrong-password)
    //   print(e.message);
    //   return null;
    // }
    return null; // Placeholder
  }

  // Example: Sign out
  Future<void> signOut() async {
    // await _firebaseAuth.signOut();
  }
}

// Riverpod provider for the FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Riverpod provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

// Riverpod stream provider for auth state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
}); 