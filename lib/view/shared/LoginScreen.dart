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
    final double screenHeight = MediaQuery.of(context).size.height;

    return GlassScaffold(
      child: Directionality(
        textDirection: TextDirection.rtl, // لدعم اللغة العربية بشكل صحيح
        child: Column(
          children: [
            const Icon(
              Icons.directions_car_filled_rounded,
              color: Color(0xFFE55757),
              size: 80,
            ),

            SizedBox(height: screenHeight * 0.02),

            const Text(
              "مرحباً بعودتك",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            GlassCard(
              child: Column(
                children: [
                  // ================= EMAIL =================
                  Obx(
                    () => GlassTextField(
                      controller: emailController,
                      hint: "اسم المستخدم / البريد الإلكتروني",
                      prefixIcon: Icons.person_outline,
                      hasError: controller.emailError.value.isNotEmpty,
                    ),
                  ),

                  Obx(
                    () => controller.emailError.value.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Align(
                              alignment: Alignment.centerRight,
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
                        hint: "كلمة المرور",
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
                              alignment: Alignment.centerRight,
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
                    alignment: Alignment.centerLeft, // تم التعديل لتناسب الاتجاه العربي
                    child: GestureDetector(
                      onTap: () => Get.to(() => ForgotPasswordScreen()),
                      child: const Text(
                        "هل نسيت كلمة المرور؟",
                        style: TextStyle(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // ================= LOGIN BUTTON =================
                  Obx(
                    () => CustomButton(
                      text: controller.isLoading.value ? "جارٍ التحميل..." : "تسجيل الدخول",
                      onTap: () {
                        controller.handleLogin(
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            TextButton(
              onPressed: () => Get.to(() => SignUpScreen()),
              child: const Text(
                "ليس لديك حساب؟ إنشاء حساب جديد",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}