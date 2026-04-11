import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    final email = args?["email"] ?? "";
    final code = args?["code"] ?? "";

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Email: $email"),
            const SizedBox(height: 10),
            Text("Code: $code"),
          ],
        ),
      ),
    );
  }
}