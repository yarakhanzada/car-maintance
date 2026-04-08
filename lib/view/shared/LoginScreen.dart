import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/LoginController.dart';
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
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          GlassCard(
            child: Column(
              children: [
                // حقل البريد الإلكتروني
                GlassTextField(
                  controller: emailController,
                  hint: "Username / Email",
                  prefixIcon: Icons.person_outline,
                ),

                const SizedBox(height: 20),

                Obx(
                  () => GlassTextField(
                    controller: passwordController,
                    hint: "Password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: controller.isPasswordHidden.value,
                    suffixIcon: _buildPasswordIcon(),
                  ),
                ),

                const SizedBox(height: 15),
                _buildForgotPasswordLink(),

                const SizedBox(height: 30),

                CustomButton(
                  text: "LOGIN",
                  onTap: () {
                    // controller.login(
                    //   email: emailController.text.trim(),
                    //   password: passwordController.text,
                    // );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
          _buildSignUpLink(),
        ],
      ),
    );
  }

  Widget _buildPasswordIcon() {
    return IconButton(
      icon: Icon(
        controller.isPasswordHidden.value
            ? Icons.visibility_off
            : Icons.visibility,
        color: Colors.white70,
        size: 20,
      ),
      onPressed: controller.togglePasswordVisibility,
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Get.to(() => const ForgotPasswordScreen()),
        child: Text(
          "Forgot Password?",
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return TextButton(
      onPressed: () => Get.to(() => SignUpScreen()),
      child: RichText(
        text: const TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: Colors.white70),
          children: [
            TextSpan(
              text: "Sign Up",
              style: TextStyle(
                color: Color(0xFFE55757),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
