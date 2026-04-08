import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/view/shared/OTPScreen.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:senior_project/widgets/GlassTextField.dart';
import 'package:senior_project/widgets/GlassScaffold.dart';
import 'package:senior_project/widgets/AuthHeaderIcon.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AuthHeaderIcon(icon: Icons.lock_reset_rounded),
          const SizedBox(height: 40),
          const Text(
            "Password Recovery",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Enter your email to receive a reset link",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 50),
          const GlassTextField(
            hint: "Email Address",
            prefixIcon: Icons.email_rounded,
          ),
          const SizedBox(height: 35),
          CustomButton(
            text: "Send Reset Link",
            onTap: () => Get.to(
              () => const OTPScreen(),
              transition: Transition.rightToLeftWithFade,
            ),
          ),
        ],
      ),
    );
  }
}
