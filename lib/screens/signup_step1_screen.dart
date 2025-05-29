// lib/screens/signup_step1_screen.dart
import 'package:flutter/material.dart';
import '../models/signup_data.dart';
import 'signup_step2_screen.dart';

class SignupStep1Screen extends StatefulWidget {
  final SignupData signupData;

  const SignupStep1Screen({super.key, required this.signupData});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    // Update shared SignupData object
    widget.signupData.username = _emailController.text;
    widget.signupData.password = _passwordController.text;

    // Navigate to Step 2
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupStep2Screen(signupData: widget.signupData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up (1/4)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _goToNextStep,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
