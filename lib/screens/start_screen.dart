import 'package:flutter/material.dart';
import '../models/signup_data.dart';
import '../screens/home_page.dart';

class StartScreen extends StatelessWidget {
  final SignupData signupData;
  final genderText = ['Female', 'Male', 'Prefer not to say'];
  final skinTypeText = ['Dry', 'Oily', 'Combination', 'Normal', 'Dry & Oily'];


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
              Text('Gender: ${signupData.gender >= 0 && signupData.gender < genderText.length
                  ? genderText[signupData.gender]
                  : 'Unknown'}'),

              Text('Skin Type: ${signupData.skinType >= 0 && signupData.skinType < skinTypeText.length
                  ? skinTypeText[signupData.skinType]
                  : 'Unknown'}'),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
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
