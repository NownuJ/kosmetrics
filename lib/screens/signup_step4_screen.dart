// lib/screens/signup_step4_screen.dart
import 'package:flutter/material.dart';
import '../models/signup_data.dart';
import '../screens/start_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupStep4Screen extends StatefulWidget {
  final SignupData signupData;

  const SignupStep4Screen({super.key, required this.signupData});

  @override
  State<SignupStep4Screen> createState() => _SignupStep4ScreenState();
}

class _SignupStep4ScreenState extends State<SignupStep4Screen> {
  String? _selectedSkinType;
  final List<String> _skinTypes = ['Dry', 'Oily', 'Combination', 'Normal', 'Dry & Oily'];

  void _goToNextStep() async {
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
        case 'Dry & Oily':
          widget.signupData.skinType = 4;
          break;
      }
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: widget.signupData.username,
        password: widget.signupData.password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'nickname': widget.signupData.nickname,
        'age': widget.signupData.age,
        'gender': widget.signupData.gender,
        'skinType': widget.signupData.skinType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StartScreen(signupData: widget.signupData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error in Sign up: ${e.toString()}")),
      );
    }
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
