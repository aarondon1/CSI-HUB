import 'package:flutter/material.dart';
import 'package:dolphin_finder/signup_signin.dart';
import 'package:dolphin_finder/signup.dart';
import 'package:dolphin_finder/signin.dart';
import 'package:dolphin_finder/home.dart';
import 'package:dolphin_finder/newprojectpage.dart';
import 'package:dolphin_finder/settings.dart';
import 'package:dolphin_finder/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dolphin Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignUpSignInPage(),
      //home: const SignUpPage(),
      //home: const SignInPage(),
      //home: const HomePage(),
      //home: const NewProjectPage(),
      //home: const SettingsPage(),
      //home: const ProfilePage(),
    );
  }
}
