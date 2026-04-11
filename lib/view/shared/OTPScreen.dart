import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/otp_controller.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:senior_project/widgets/OTPSquare.dart';
import 'package:senior_project/widgets/GlassScaffold.dart';
import 'package:senior_project/widgets/AuthHeaderIcon.dart';

class OTPScreen extends StatelessWidget {
  OTPScreen({super.key});

  final OTPController controller = Get.put(OTPController());
  final String email = Get.arguments['email'];
  final String type = Get.arguments['type'];
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
          const SizedBox(height: 15),
          Text(
            "Sent to $email",
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),

          const SizedBox(height: 50),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return OTPSquare(
                onChanged: (value) {
                  controller.otpCodes[index] = value;
                },
              );
            }),
          ),

          const SizedBox(height: 40),

          Obx(
            () => controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.redAccent)
                : CustomButton(
                    text: "Verify & Proceed",
                    onTap: () => controller.verifyOTP(email, type),
                  ),
          ),

          const SizedBox(height: 30),
          _buildResendSection(),
        ],
      ),
    );
  }

  Widget _buildResendSection() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Didn't receive code? ",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          controller.isResending.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFE55757),
                  ),
                )
              : TextButton(
                  onPressed: controller.enableResend.value
                      ? () => controller.resendCode(email)
                      : null,
                  child: Text(
                    controller.enableResend.value
                        ? "Resend Now"
                        : "Resend (${controller.formattedTime})",
                    style: TextStyle(
                      color: controller.enableResend.value
                          ? const Color(0xFFE55757)
                          : Colors.white30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      );
    });
  }
}
