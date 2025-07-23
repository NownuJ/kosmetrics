import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ranking_list_page.dart';

class PersonalRecommendationPage extends StatefulWidget {
  const PersonalRecommendationPage({super.key});

  @override
  State<PersonalRecommendationPage> createState() => _PersonalRecommendationPageState();
}

class _PersonalRecommendationPageState extends State<PersonalRecommendationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> skinTypeOptions = ['Dry', 'Oily', 'Combination', 'Normal', 'Dry & Oily'];

  @override
  void initState() {
    super.initState();
    _loadAndRedirect();
  }

  Future<void> _loadAndRedirect() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data == null) return;

    final int age = data['age'] ?? 0;
    final int skinTypeIndex = data['skinType'] ?? 0;

    final String selectedAge = _mapAgeToString(age);
    final String selectedSkinType = skinTypeOptions[skinTypeIndex];

    // Navigate directly to RankingListPage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RankingListPage(
            selectedAge: selectedAge,
            selectedSkinType: selectedSkinType,
          ),
        ),
      );
    });
  }

  String _mapAgeToString(int age) {
    if (age < 30) return '10/20s';
    if (age < 40) return '30s';
    if (age < 50) return '40s';
    if (age < 60) return '50s';
    return '60s+';
  }

  @override
  Widget build(BuildContext context) {
    // Just show a loading screen while redirecting
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
