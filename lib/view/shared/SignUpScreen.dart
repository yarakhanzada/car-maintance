import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/SignUpController.dart';
import 'package:senior_project/view/shared/OTPScreen.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:senior_project/widgets/GlassCard.dart';
import 'package:senior_project/widgets/GlassTextField.dart';
import 'package:senior_project/widgets/GlassScaffold.dart';

class SignUpScreen extends StatelessWidget {
  final SignUpController controller = Get.put(SignUpController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Column(
        children: [
          const Text(
            "Create Account",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Fill in the details to get started",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 30),

          GlassCard(
            child: Column(
              children: [
                GlassTextField(
                  controller: nameController,
                  hint: "Full Name",
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 15),
                GlassTextField(
                  controller: emailController,
                  hint: "Email",
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 15),
                GlassTextField(
                  controller: phoneController,
                  hint: "Phone Number",
                  prefixIcon: Icons.phone_android,
                ),
                const SizedBox(height: 15),

                Obx(
                  () => GlassTextField(
                    controller: passwordController,
                    hint: "Password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: controller.isPasswordHidden.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: controller.toggleConfirmPassword,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                Obx(
                  () => GlassTextField(
                    controller: confirmpasswordController,
                    hint: "ConfirmPassword",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: controller.isPasswordHidden.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: controller.toggleConfirmPassword,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                CustomButton(
                  text: "SIGN UP",
                  onTap: () {
                    // منطق إرسال البيانات للباك إند
                    Get.to(() => const OTPScreen());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "Already have an account? Login",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
