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
    final double screenHeight = MediaQuery.of(context).size.height;

    return GlassScaffold(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            const Text(
              "إنشاء حساب",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            GlassCard(
              child: Column(
                children: [
                  GlassTextField(
                    controller: nameController,
                    hint: "الاسم الكامل",
                    prefixIcon: Icons.person_outline,
                  ),

                  const SizedBox(height: 15),

                  /// EMAIL
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassTextField(
                          controller: emailController,
                          hint: "البريد الإلكتروني",
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
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// PHONE
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassTextField(
                          controller: phoneController,
                          hint: "رقم الهاتف",
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
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// PASSWORD
                  Obx(
                    () => GlassTextField(
                      controller: passwordController,
                      hint: "كلمة المرور",
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: controller.isPasswordHidden.value,
                      hasError: controller.passwordErrors.isNotEmpty,
                      onChanged: (value) {
                        controller.validatePasswordLive(value);
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePassword,
                      ),
                    ),
                  ),

                  const SizedBox(height: 1),

                  /// PASSWORD ERRORS
                  Obx(() {
                    if (controller.passwordErrors.isEmpty) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8, right: 5),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              controller.passwordErrors.first,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 15),

                  /// CONFIRM PASSWORD
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassTextField(
                          controller: confirmPasswordController,
                          hint: "تأكيد كلمة المرور",
                          prefixIcon: Icons.lock_reset_outlined,
                          isPassword: true,
                          obscureText: controller.isConfirmPasswordHidden.value,
                          hasError: controller.confirmPasswordError.isNotEmpty,
                          onChanged: (value) {
                            if (value != passwordController.text) {
                              controller.confirmPasswordError.value =
                                  "كلمتا المرور غير متطابقتين";
                            } else {
                              controller.confirmPasswordError.value = "";
                            }
                          },
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
                          Padding(
                            padding: const EdgeInsets.only(top: 5, right: 10),
                            child: Text(
                              controller.confirmPasswordError.value,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  /// BUTTON
                  Obx(
                    () => CustomButton(
                      text: controller.isLoading.value ? "جارٍ التحميل..." : "إنشاء حساب",
                      onTap: () async {
                        var result = await controller.signUp(
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          password: passwordController.text,
                          confirmPassword: confirmPasswordController.text,
                        );
                      
                        if (result != null && result.status == 1) {
                          Get.to(
                            () => OTPScreen(),
                            arguments: {
                              "email": emailController.text,
                              "type": "signup",
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}