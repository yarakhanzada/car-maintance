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

  final ForgotPasswordController controller = Get.put(
    ForgotPasswordController(),
  );

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return GlassScaffold(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            const AuthHeaderIcon(icon: Icons.lock_reset_rounded),

            SizedBox(height: screenHeight * 0.04),

            const Text(
              "استعادة كلمة المرور",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "أدخل بريدك الإلكتروني لإرسال رمز إعادة التعيين",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            SizedBox(height: screenHeight * 0.05),

            // ================= EMAIL FIELD =================
            Obx(
              () => GlassTextField(
                controller: emailController,
                hint: "البريد الإلكتروني",
                prefixIcon: Icons.email_rounded,
                hasError: controller.emailError.value.isNotEmpty,
              ),
            ),

            //  error under field
            Obx(
              () => controller.emailError.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          controller.emailError.value,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),

            SizedBox(height: screenHeight * 0.04),

            // ================= BUTTON =================
            Obx(
              () => CustomButton(
                text: controller.isLoading.value
                    ? "جارٍ التحميل..."
                    : "إرسال رمز إعادة التعيين",
                onTap: () async {
                  bool success = await controller.sendResetCode(
                    emailController.text.trim(),
                  );

                  if (success) {
                    Get.to(
                      () => OTPScreen(),
                      arguments: {
                        "email": emailController.text.trim(),
                        "type": "reset",
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}