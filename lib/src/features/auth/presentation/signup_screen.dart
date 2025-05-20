import 'package:firebase_auth/firebase_auth.dart'; // Import for UserCredential
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:push_pal/src/features/auth/application/auth_service.dart';
import 'package:push_pal/src/features/auth/application/user_profile_service.dart'; // Import UserProfileService
import 'package:push_pal/src/features/auth/domain/user_profile.dart'; // Import UserProfile model

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final authService = ref.read(authServiceProvider);
        print('[UI - SignupScreen] Calling authService.signUpWithEmailAndPassword');
        
        // Step 1: Create Firebase Auth user
        final UserCredential? userCredential = await authService.signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          displayName: _nameController.text.trim(), // This updates Firebase Auth user profile
        );
        print('[UI - SignupScreen] Firebase Auth signUp successful.');

        if (userCredential?.user != null) {
          print('[UI - SignupScreen] Creating initial Firestore user profile stub.');
          // Step 2: Create initial UserProfile document in Firestore
          final newUserProfile = UserProfile(
            uid: userCredential!.user!.uid,
            email: userCredential.user!.email,
            displayName: _nameController.text.trim(), // Or userCredential.user!.displayName
            profileSetupComplete: false, // IMPORTANT: Mark as incomplete
            // createdAt will be set by server timestamp in toMap()
          );
          await ref.read(userProfileServiceProvider).setUserProfile(newUserProfile);
          print('[UI - SignupScreen] Firestore user profile stub created.');
        } else {
           print('[UI - SignupScreen] UserCredential or user is null after signup.');
           // This case should ideally not happen if signUpWithEmailAndPassword was successful
           // and didn't throw an exception that was caught by the AuthServiceException handler below.
           // If it does, it might indicate an issue with how Firebase Auth returns the user or an error not caught.
           throw AuthServiceException("Signup completed but user data not found.");
        }
        
        // Navigation is handled by GoRouter's redirect logic based on auth state 
        // and (soon) profileSetupComplete status.

      } on AuthServiceException catch (e) {
        print('[UI - SignupScreen] Caught AuthServiceException: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      } catch (e) {
        print('[UI - SignupScreen] Caught Generic Exception: ${e.toString()}, Type: ${e.runtimeType}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred. Please try again.')),
          );
        }
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              SizedBox(
                height: 100, // Slightly smaller for signup screen maybe
                child: Image.asset(
                  'assets/images/pushpal.png', 
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Join PushPal',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) { // Basic password length check
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.password_rounded)),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                    : const Text('Sign Up'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      context.go('/login'); // Navigate to Login screen
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 