import 'package:flutter/material.dart';

class AuthHeaderIcon extends StatelessWidget {
  final IconData icon;

  const AuthHeaderIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.09),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Icon(icon, size: 60, color: const Color(0xFFE55757)),
    );
  }
}
