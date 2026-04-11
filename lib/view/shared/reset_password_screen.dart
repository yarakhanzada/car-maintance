import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/reset_password_controller.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:senior_project/widgets/GlassTextField.dart';
import 'package:senior_project/widgets/GlassScaffold.dart';
import 'package:senior_project/widgets/AuthHeaderIcon.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String email = Get.arguments['email'];
  final String code = Get.arguments['code'];

  final ResetPasswordController controller = Get.put(ResetPasswordController());
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Column(
        children: [
          const AuthHeaderIcon(icon: Icons.lock_open_rounded),
          const SizedBox(height: 30),
          const Text(
            "New Password",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Resetting password for $email",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 40),

          Obx(
            () => GlassTextField(
              controller: passwordController,
              hint: "New Password",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              obscureText: controller.obscurePassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () => controller.obscurePassword.toggle(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Obx(
            () => GlassTextField(
              controller: confirmPasswordController,
              hint: "Confirm Password",
              prefixIcon: Icons.lock_reset_outlined,
              isPassword: true,
              obscureText: controller.obscureConfirm.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureConfirm.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () => controller.obscureConfirm.toggle(),
              ),
            ),
          ),

          const SizedBox(height: 40),

          Obx(
            () => controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.redAccent)
                : CustomButton(
                    text: "Update Password",
                    onTap: () => controller.resetPassword(
                      email: email,
                      code: code,
                      password: passwordController.text,
                      confirmPassword: confirmPasswordController.text,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
