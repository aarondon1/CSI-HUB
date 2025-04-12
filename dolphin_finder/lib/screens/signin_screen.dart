import 'package:dolphin_finder/widgets/custom_scaffold.dart';
import 'package:dolphin_finder/widgets/welcome_button.dart';
import 'package:flutter/material.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Align(
        alignment: FractionalOffset(0.5, 0.005), // (0.5, 0.5) = Center of screen
        child: Column(
          mainAxisSize: MainAxisSize.min, // So it only takes up needed space
          children: [
            Text(
              'Dolphin Finder',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30), // Space between text and image
            SizedBox(
              width: 200,
              height: 200,
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(height: 20),
            Text(
                "Sign In",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w200
              ),
            ),
            Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                                children: [
                  Expanded(
                      child: WelcomeButton(
                        buttonText: 'Sign Up',
                      )
                  )
                                ],
                              ),
                )
            )
          ],
        ),
      ),
    );
  }
}

