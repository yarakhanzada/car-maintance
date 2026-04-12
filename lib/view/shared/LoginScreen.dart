import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/LoginController.dart';
import 'package:senior_project/view/client/ClientBottombar.dart';
import 'package:senior_project/view/shared/SignUpScreen.dart';
import 'package:senior_project/view/shared/ForgotPasswordScreen.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:senior_project/widgets/GlassCard.dart';
import 'package:senior_project/widgets/GlassTextField.dart';
import 'package:senior_project/widgets/GlassScaffold.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Column(
        children: [
          const Icon(
            Icons.directions_car_filled_rounded,
            color: Color(0xFFE55757),
            size: 80,
          ),

          const SizedBox(height: 20),

          const Text(
            "Welcome Back",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          GlassCard(
            child: Column(
              children: [
                // ================= EMAIL =================
                Obx(
                  () => GlassTextField(
                    controller: emailController,
                    hint: "Username / Email",
                    prefixIcon: Icons.person_outline,
                    hasError: controller.emailError.value.isNotEmpty,
                  ),
                ),

                Obx(
                  () => controller.emailError.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 5),
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
                      : const SizedBox(),
                ),

                const SizedBox(height: 15),

                // ================= PASSWORD =================
             Obx(() => GlassTextField(
  controller: passwordController,
  hint: "Password",
  prefixIcon: Icons.lock_outline,
  isPassword: true,
  obscureText: controller.isPasswordHidden.value,
  hasError: controller.passwordError.value.isNotEmpty,
  suffixIcon: IconButton(
    icon: Icon(
      controller.isPasswordHidden.value
          ? Icons.visibility_off
          : Icons.visibility,
      color: Colors.white70,
    ),
    onPressed: controller.togglePasswordVisibility,
  ),
)),

                Obx(
                  () => controller.passwordError.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.passwordError.value,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),

                const SizedBox(height: 15),

                // ================= FORGOT PASSWORD =================
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.to(() => ForgotPasswordScreen()),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= LOGIN BUTTON =================
                Obx(
                  () => CustomButton(
                    text: controller.isLoading.value ? "Loading..." : "LOGIN",
                    onTap: () async {
                      var result = await controller.login(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                      );

                      if (result != null && result.status == 1) {
                        await controller.saveSession(result);
                        Get.offAll(ClientBottombar());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          TextButton(
            onPressed: () => Get.to(() => SignUpScreen()),
            child: const Text(
              "Don't have an account? Sign Up",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
