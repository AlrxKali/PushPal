import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:push_pal/src/features/auth/application/auth_service.dart'; // Uncommented and used

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // To show a loading indicator on the button

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final authService = ref.read(authServiceProvider);
        print('[UI - LoginScreen] Calling authService.signInWithEmailAndPassword'); // DEBUG PRINT
        await authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print('[UI - LoginScreen] signInWithEmailAndPassword call completed (no exception caught here)'); // DEBUG PRINT
        // Navigation is handled by authStateChangesProvider via SplashScreen logic or router redirects
        // No explicit navigation here on success is needed if setup correctly.
      } on AuthServiceException catch (e) {
        print('[UI - LoginScreen] Caught AuthServiceException: ${e.message}'); // DEBUG PRINT
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      } catch (e) {
        print('[UI - LoginScreen] Caught Generic Exception: ${e.toString()}, Type: ${e.runtimeType}'); // DEBUG PRINT
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
    // final authState = ref.watch(authStateChangesProvider); // Example of watching auth state

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome Back!')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20), // Adjusted spacing
              // Display the app icon
              SizedBox(
                height: 120, // Adjust height as needed
                child: Image.asset(
                  'assets/images/pushpal.png', // Updated image path
                  fit: BoxFit.contain, // Adjust fit as needed (e.g., BoxFit.cover)
                ),
              ),
              const SizedBox(height: 20), // Adjusted spacing
              Text(
                'Log in to PushPal',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30), // Adjusted spacing
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) { // Basic email validation
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
                    return 'Please enter your password';
                  }
                  // Add more password validation if needed (e.g., length)
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password functionality
                    print('Forgot password pressed');
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                    : const Text('Login'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      context.go('/signup'); // Navigate to Signup screen
                    },
                    child: const Text('Sign Up'),
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