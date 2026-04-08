import 'package:flutter/material.dart';

class CustomTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign textAlign;

  const CustomTitle({
    super.key,
    required this.text,
    this.fontSize = 28,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }
}
