// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_step1_screen.dart';
import 'screens/signup_step2_screen.dart';
import 'screens/PlaceholderPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup Flow Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup_step1': (context) => SignupStep1Screen(),
        '/signup_step2': (context) => SignupStep2Screen(),
        '/signup_step3': (context) => PlaceholderPage('Sign Up 3/4'),
        '/signup_step4': (context) => PlaceholderPage('Sign Up 4/4'),
        '/welcome_user': (context) => PlaceholderPage('Welcome User'),
        '/home': (context) => PlaceholderPage('Home'),
        // to navigate through routes,
        // use Navigator.pushNamed(context, '/route_name')
      },

    );
  }
}
