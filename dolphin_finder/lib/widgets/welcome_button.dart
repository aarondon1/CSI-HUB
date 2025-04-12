import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({super.key, this.buttonText});
  final String? buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50)
          )
        ),
        child: Text(
          buttonText!,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
        )
    );
  }
}
