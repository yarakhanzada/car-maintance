import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/otp_controller.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:senior_project/widgets/OTPSquare.dart';
import 'package:senior_project/widgets/GlassScaffold.dart';
import 'package:senior_project/widgets/AuthHeaderIcon.dart';

class OTPScreen extends StatelessWidget {
  OTPScreen({super.key});

  final OTPController controller = Get.put(OTPController());
  final String email = Get.arguments['email'];
  final String type = Get.arguments['type'];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return GlassScaffold(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            const AuthHeaderIcon(icon: Icons.vibration_rounded),

            SizedBox(height: screenHeight * 0.03),

            const Text(
              "رمز التحقق",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "تم إرسال الرمز إلى $email",
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
              textDirection: TextDirection.ltr,
            ),

            SizedBox(height: screenHeight * 0.05),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return OTPSquare(
                  onChanged: (value) {
                    controller.otpCodes[index] = value;
                  },
                );
              }),
            ),

            SizedBox(height: screenHeight * 0.04),

            Obx(
              () => controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.redAccent)
                  : CustomButton(
                      text: "التحقق والمتابعة",
                      onTap: () => controller.verifyOTP(email, type),
                    ),
            ),

            SizedBox(height: screenHeight * 0.03),

            if (type == "signup") _buildResendSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "لم تصلك الرسالة؟ ",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),

          controller.isResending.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFE55757),
                  ),
                )
              : TextButton(
                  onPressed: controller.enableResend.value
                      ? () => controller.resendCode(email)
                      : null,
                  child: Text(
                    controller.enableResend.value
                        ? "أعد الإرسال الآن"
                        : "إعادة الإرسال خلال (${controller.formattedTime})",
                    style: TextStyle(
                      color: controller.enableResend.value
                          ? const Color(0xFFE55757)
                          : Colors.white30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      );
    });
  }
}
