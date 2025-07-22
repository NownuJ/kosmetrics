import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyInfoPage extends StatefulWidget {
  const MyInfoPage({super.key});

  @override
  State<MyInfoPage> createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  String? _selectedGender;
  String? _selectedAge;
  String? _selectedSkinType;

  final List<String> genderOptions = ['Female', 'Male', 'Prefer not to say'];
  final List<String> ageOptions = ['20s', '30s', '40s', '50s', '60s+'];
  final List<String> skinTypeOptions = [
    'Dry',
    'Oily',
    'Combination',
    'Normal',
    'Dry & Oily'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data == null) return;

    setState(() {
      _emailController.text = user.email ?? '-';
      _nicknameController.text = data['nickname'] ?? '-';

      final genderIndex = data['gender'];
      if (genderIndex is int && genderIndex >= 0 && genderIndex < genderOptions.length) {
        _selectedGender = genderOptions[genderIndex];
      }

      _selectedAge = _ageToString(data['age']);
      _selectedSkinType = _skinTypeToString(data['skinType']);
    });
  }

  String? _ageToString(dynamic age) {
    if (age is int) {
      if (age < 30) return '20s';
      if (age < 40) return '30s';
      if (age < 50) return '40s';
      if (age < 60) return '50s';
      return '60s+';
    } else if (age is String) {
      return age;
    }
    return null;
  }

  String? _skinTypeToString(dynamic index) {
    if (index is int && index >= 0 && index < skinTypeOptions.length) {
      return skinTypeOptions[index];
    }
    return null;
  }

  int? _ageStringToInt(String? ageStr) {
    switch (ageStr) {
      case '20s':
        return 23;
      case '30s':
        return 33;
      case '40s':
        return 43;
      case '50s':
        return 53;
      case '60s+':
        return 63;
    }
    return null;
  }

  int? _skinTypeToIndex(String? skin) {
    if (skin == null) return null;
    return skinTypeOptions.indexOf(skin);
  }

  int? _genderToIndex(String? gender) {
    if (gender == null) return null;
    return genderOptions.indexOf(gender);
  }

  Future<void> _saveUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'gender': _genderToIndex(_selectedGender),
      'age': _ageStringToInt(_selectedAge),
      'skinType': _skinTypeToIndex(_selectedSkinType),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User info updated')),
      );
    }
  }

  Widget _buildToggleGroup<T>({
    required String label,
    required List<T> options,
    required T? selectedValue,
    required void Function(T) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final bool isSelected = option == selectedValue;
            return ChoiceChip(
              label: Text(option.toString()),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveUserInfo,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Email"),
            TextField(
              controller: _emailController,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            const Text("Nickname"),
            TextField(
              controller: _nicknameController,
              readOnly: true,
            ),
            _buildToggleGroup<String>(
              label: "Gender",
              options: genderOptions,
              selectedValue: _selectedGender,
              onSelected: (val) => setState(() => _selectedGender = val),
            ),
            _buildToggleGroup<String>(
              label: "Age",
              options: ageOptions,
              selectedValue: _selectedAge,
              onSelected: (val) => setState(() => _selectedAge = val),
            ),
            _buildToggleGroup<String>(
              label: "Skin Type",
              options: skinTypeOptions,
              selectedValue: _selectedSkinType,
              onSelected: (val) => setState(() => _selectedSkinType = val),
            ),
          ],
        ),
      ),
    );
  }
}
