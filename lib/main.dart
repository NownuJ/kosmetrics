// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'screens/signup_step3_screen.dart';
import 'screens/signup_step4_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_step1_screen.dart';
import 'screens/signup_step2_screen.dart';
import 'screens/placeholder_page.dart';
import 'models/user.dart';
import 'models/signup_data.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final int MALE = 0;
  final int FEMALE = 1;
  final int DRY = 0;
  final int NORMAL = 1;
  final int OILY = 2;
  final int COMBINATION = 3;
  final int DRY_OILY = 4;

  int newUserId = 0;
  List<User> users = [];
  // user has username, password, age, gender, skin type


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup Flow Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(signupData: SignupData()),
        '/login': (context) => LoginScreen(),
        '/signup_step1': (context) => SignupStep1Screen(signupData: SignupData()),
        '/signup_step2': (context) => SignupStep2Screen(signupData: SignupData()),
        '/signup_step3': (context) => SignupStep3Screen(signupData: SignupData()),
        '/signup_step4': (context) => SignupStep4Screen(signupData: SignupData()),
        '/welcome_user': (context) => PlaceholderPage('Welcome User'),
        '/home': (context) => PlaceholderPage('Home'),



        // to navigate through routes,
        // use Navigator.pushNamed(context, '/route_name')
      },
    );
  }
}
