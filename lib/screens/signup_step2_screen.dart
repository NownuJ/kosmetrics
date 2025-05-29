// lib/screens/signup_step2_screen.dart
import 'package:flutter/material.dart';

class SignupStep2Screen extends StatelessWidget {
  const SignupStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up (2/4)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nickname Input Placeholder'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // You’ll go to step 3 later
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
