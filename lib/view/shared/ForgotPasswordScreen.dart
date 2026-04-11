import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/forgot_password_controller.dart';
import 'package:senior_project/view/shared/OTPScreen.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:senior_project/widgets/GlassTextField.dart';
import 'package:senior_project/widgets/GlassScaffold.dart';
import 'package:senior_project/widgets/AuthHeaderIcon.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());

  final TextEditingController emailController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Column(
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
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 50),

          // ================= EMAIL FIELD =================
          Obx(() => GlassTextField(
                controller: emailController,
                hint: "Email Address",
                prefixIcon: Icons.email_rounded,
                hasError: controller.emailError.value.isNotEmpty,
              )),

          // 🔴 error under field
          Obx(() => controller.emailError.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      controller.emailError.value,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              : const SizedBox()),

          const SizedBox(height: 35),

          // ================= BUTTON =================
          Obx(() => CustomButton(
                text: controller.isLoading.value
                    ? "Loading..."
                    : "Send Reset Code",
                onTap: () async {
                  bool success = await controller.sendResetCode(
                    emailController.text.trim(),
                  );

                  if (success) {
                    Get.to(
                      () => OTPScreen(),
                      arguments: {
                        "email": emailController.text.trim(),
                      },
                    );
                  }
                },
              )),
        ],
      ),
    );
  }
}