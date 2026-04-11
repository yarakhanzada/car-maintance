import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/SignUpController.dart';
import 'package:senior_project/view/shared/OTPScreen.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:senior_project/widgets/GlassCard.dart';
import 'package:senior_project/widgets/GlassTextField.dart';
import 'package:senior_project/widgets/GlassScaffold.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final SignUpController controller = Get.put(SignUpController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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

                /// EMAIL
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassTextField(
                          controller: emailController,
                          hint: "Email",
                          prefixIcon: Icons.email_outlined,
                          hasError: controller.emailError.isNotEmpty,
                        ),
                        if (controller.emailError.isNotEmpty)
                          Text(
                            controller.emailError.value,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    )),

                const SizedBox(height: 15),

                /// PHONE
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassTextField(
                          controller: phoneController,
                          hint: "Phone Number",
                          prefixIcon: Icons.phone_android,
                          hasError: controller.phoneError.isNotEmpty,
                        ),
                        if (controller.phoneError.isNotEmpty)
                          Text(
                            controller.phoneError.value,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    )),

                const SizedBox(height: 15),

                /// PASSWORD
                Obx(() => GlassTextField(
                      controller: passwordController,
                      hint: "Password",
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: controller.isPasswordHidden.value,
                      hasError: controller.passwordErrors.isNotEmpty,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePassword,
                      ),
                    )),

                const SizedBox(height: 10),

                /// PASSWORD ERRORS
                Obx(() {
                  if (controller.passwordErrors.isEmpty) {
                    return const SizedBox();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: controller.passwordErrors
                        .map((e) => Text(
                              "• $e",
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                  );
                }),

                const SizedBox(height: 15),

                /// CONFIRM PASSWORD
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassTextField(
                          controller: confirmPasswordController,
                          hint: "Confirm Password",
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          obscureText:
                              controller.isConfirmPasswordHidden.value,
                          hasError:
                              controller.confirmPasswordError.isNotEmpty,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: controller.toggleConfirmPassword,
                          ),
                        ),

                        if (controller.confirmPasswordError.isNotEmpty)
                          Text(
                            controller.confirmPasswordError.value,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    )),

                const SizedBox(height: 20),

                /// BUTTON
                Obx(() => CustomButton(
                      text: controller.isLoading.value
                          ? "Loading..."
                          : "SIGN UP",
                      onTap: () async {
                        var result = await controller.signUp(
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          password: passwordController.text,
                          confirmPassword:
                              confirmPasswordController.text,
                        );

                        if (result != null && result.status == 1) {
                          Get.to(() => OTPScreen(),
                              arguments: {
                                "email": result.data.email,
                                "code":
                                    result.data.verifiedCode.toString(),
                              });
                        }
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}