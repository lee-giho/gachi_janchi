import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onPressed;

  SocialLoginButton({
    required this.text,
    required this.bgColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text),
      ),
    );
  }
}
