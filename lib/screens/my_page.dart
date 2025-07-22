import 'package:flutter/material.dart';
import 'myinfo_page.dart';
import 'personal_recommendation_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Page"),
        automaticallyImplyLeading: false,
      ),

      body: ListView(
        children: [
          ListTile(
            title: const Text("Nickname"),
            subtitle: const Text("Age / Gender / SkinType"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyInfoPage()),
              );
            },
          ),
          ListTile(
            title: const Text("Personal Recommendation"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersonalRecommendationPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
