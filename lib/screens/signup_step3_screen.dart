import 'package:flutter/material.dart';
import '../models/signup_data.dart';
import 'signup_step4_screen.dart';

class SignupStep3Screen extends StatefulWidget {
  final SignupData signupData;

  const SignupStep3Screen({super.key, required this.signupData});

  @override
  State<SignupStep3Screen> createState() => _SignupStep3ScreenState();
}

class _SignupStep3ScreenState extends State<SignupStep3Screen> {
  String? _selectedGender;
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    final ageText = _ageController.text.trim();
    final age = int.tryParse(ageText);

    if (_selectedGender == null || age == null || age <= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender and enter a valid age')),
      );
      return;
    }

    switch (_selectedGender) {
      case 'Female':
        widget.signupData.gender = 0;
        break;
      case 'Male':
        widget.signupData.gender = 1;
        break;
      case 'Prefer not to say':
        widget.signupData.gender = 2;
        break;
    }

    widget.signupData.age = age;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupStep4Screen(signupData: widget.signupData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up (3/4)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gender', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: ['Female', 'Male', 'Prefer not to say'].map((gender) {
                final isSelected = _selectedGender == gender;
                return ChoiceChip(
                  label: Text(gender),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _goToNextStep,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
