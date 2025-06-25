// lib/screens/signup_step2_screen.dart
import 'package:flutter/material.dart';
import 'package:kosmetric/screens/signup_step3_screen.dart';
import '../models/signup_data.dart';


class SignupStep2Screen extends StatefulWidget {
  final SignupData signupData;

  const SignupStep2Screen({super.key, required this.signupData});

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    widget.signupData.nickname = _nicknameController.text;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupStep3Screen(signupData: widget.signupData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up (2/4)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: 'Nickname'),
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
