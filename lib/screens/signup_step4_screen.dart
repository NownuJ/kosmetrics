// lib/screens/signup_step4_screen.dart
import 'package:flutter/material.dart';
import '../models/signup_data.dart';
import '../screens/start_screen.dart';

class SignupStep4Screen extends StatefulWidget {
  final SignupData signupData;

  const SignupStep4Screen({super.key, required this.signupData});

  @override
  State<SignupStep4Screen> createState() => _SignupStep4ScreenState();
}

class _SignupStep4ScreenState extends State<SignupStep4Screen> {
  String? _selectedSkinType;
  final List<String> _skinTypes = ['Dry', 'Oily', 'Combination', 'Normal', 'Dry and Oily'];

  void _goToNextStep() {
    if (_selectedSkinType != null) {
      switch (_selectedSkinType) {
        case 'Dry':
          widget.signupData.skinType = 0;
          break;
        case 'Oily':
          widget.signupData.skinType = 1;
          break;
        case 'Combination':
          widget.signupData.skinType = 2;
          break;
        case 'Normal':
          widget.signupData.skinType = 3;
          break;
        case 'Dry and Oily':
          widget.signupData.skinType = 4;
          break;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StartScreen(signupData: widget.signupData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up (4/4)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Skin Type', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _skinTypes.map((type) {
                final isSelected = _selectedSkinType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedSkinType = type;
                    });
                  },
                );
              }).toList(),
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
