// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:kosmetric/models/signup_data.dart';

class WelcomeScreen extends StatelessWidget {
  final SignupData signupData;

  const WelcomeScreen({super.key, required this.signupData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/kosmetrics_logo1.png'),
              const SizedBox(height: 20),
              const Text(
                'For your skin and your choices',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Log In'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup_step1');
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
