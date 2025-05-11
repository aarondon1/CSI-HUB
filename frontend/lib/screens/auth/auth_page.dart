import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_page.dart';
import 'package:frontend/screens/auth/signup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  void toggleView() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return LoginPage(toggleView: toggleView);
    } else {
      return SignupPage(toggleView: toggleView);
    }
  }
}
