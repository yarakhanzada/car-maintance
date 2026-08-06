import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/view/shared/LoginScreen.dart';
import 'package:senior_project/services/api_config.dart';
import '../services/api_helper.dart';

class ResetPasswordController extends GetxController {
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var obscureConfirm = true.obs;

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      Get.snackbar(
        "خطأ",
        "كلمات المرور غير متطابقة",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      var response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/reset-password",
        {
          "email": email.trim(),
          "code": code.trim(),
          "password": password,
          "password_confirmation": confirmPassword,
        },
        skipAuth: true,
      );

      var jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        Get.snackbar(
          "نجاح",
          jsonData['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(() => LoginScreen());
      } else {
        Get.snackbar(
          "خطأ",
          jsonData['message'] ?? "فشلت عملية إعادة التعيين",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل الاتصال بالخادم");
    } finally {
      isLoading.value = false;
    }
  }
}