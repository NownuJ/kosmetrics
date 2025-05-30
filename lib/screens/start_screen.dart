// lib/screens/start_screen.dart
import 'package:flutter/material.dart';
import '../models/signup_data.dart';
import '../screens/placeholder_page.dart';


class StartScreen extends StatelessWidget {
  final SignupData signupData;
  final genderText = ['Male', 'Female', 'PNTS'];
  final skinTypeText = ['Dry', 'Oily', 'Combination', 'Normal', 'Dry and Oily'];


  StartScreen({super.key, required this.signupData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${signupData.nickname}!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Age: ${signupData.age}'),
              Text('Gender: ${genderText[signupData.gender]}'),
              Text('Skin Type: ${skinTypeText[signupData.skinType]}'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlaceholderPage('Home'),
                    ),
                  );
                },
                child: const Text("Let's start!"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
