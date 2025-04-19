import 'package:dolphin_finder/widgets/custom_scaffold.dart';
import 'package:dolphin_finder/widgets/welcome_button.dart';
import 'package:dolphin_finder/screens/actsignin_screen.dart';
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

            const SizedBox(height: 30), // Space between text and image
            SizedBox(
              width: 250,
              height: 250,
              child: Image.asset('assets/images/newlogo.png'),
            ),
            //Spacer(),
            //const SizedBox(height: 100),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "A community is awaiting your call "
                    "to breath life into your ideas",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 100),
              child: SizedBox(
                width: double.infinity,
                child: WelcomeButton(
                  buttonText: 'Sign Up',
                ),

              ),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActsigninScreen()),);
              },

              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Log in',
                      style: TextStyle(
                        color: Color(0xFF4A90E2), // Blue color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

