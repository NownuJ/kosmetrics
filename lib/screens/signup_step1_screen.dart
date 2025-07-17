// lib/screens/signup_step1_screen.dart
import 'package:flutter/material.dart';
import '../models/signup_data.dart';
import 'signup_step2_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void _goToNextStep() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      await user?.delete();

      widget.signupData.username = email;
      widget.signupData.password = password;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignupStep2Screen(signupData: widget.signupData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("The password must be at least 6 characters. ${e.toString()}")),
      );
    }
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