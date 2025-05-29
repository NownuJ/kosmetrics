// lib/screens/signup_step1_screen.dart
import 'package:flutter/material.dart';

class SignupStep1Screen extends StatelessWidget {
  const SignupStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up (1/4)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Email and Password Form Placeholder'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup_step2');
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}