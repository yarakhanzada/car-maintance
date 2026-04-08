import 'package:flutter/material.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:senior_project/widgets/OTPSquare.dart';
import 'package:senior_project/widgets/GlassScaffold.dart';
import 'package:senior_project/widgets/AuthHeaderIcon.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Column(
        children: [
          const AuthHeaderIcon(icon: Icons.vibration_rounded),
          const SizedBox(height: 30),
          const Text(
            "Verification Code",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter the 6-digit code sent to your email",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 50),

          // صف مربعات الـ OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => const OTPSquare()),
          ),

          const SizedBox(height: 40),
          CustomButton(
            text: "Verify & Proceed",
            onTap: () {
              // Get.offAll(() => HomeByRole());
            },
          ),
          const SizedBox(height: 30),
          _buildResendSection(),
        ],
      ),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Didn't receive code? ",
          style: TextStyle(color: Colors.white54),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Resend",
            style: TextStyle(color: Color(0xFFE55757)),
          ),
        ),
      ],
    );
  }
}
