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
    final double screenHeight = MediaQuery.of(context).size.height;

    return GlassScaffold(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            const AuthHeaderIcon(icon: Icons.lock_open_rounded),
            SizedBox(height: screenHeight * 0.03),
            const Text(
              "كلمة مرور جديدة",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "إعادة تعيين كلمة المرور للحساب: $email",
              style: const TextStyle(color: Colors.white70),
            ),

            SizedBox(height: screenHeight * 0.04),

            Obx(
              () => GlassTextField(
                controller: passwordController,
                hint: "كلمة المرور الجديدة",
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
                hint: "تأكيد كلمة المرور",
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

            SizedBox(height: screenHeight * 0.04),

            Obx(
              () => controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.redAccent)
                  : CustomButton(
                      text: "تحديث كلمة المرور",
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
      ),
    );
  }
}