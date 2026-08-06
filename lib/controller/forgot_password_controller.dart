import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/services/api_config.dart';
import '../services/api_helper.dart';

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;
  var emailError = "".obs;

  Future<bool> sendResetCode(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      emailError.value = "يرجى إدخال عنوان بريد إلكتروني صالح";
      return false;
    }

    emailError.value = "";
    isLoading.value = true;

    try {
      var response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/forgot-password",
        {
          "email": email,
        },
        skipAuth: true,
      );

      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 1) {
        return true;
      } else {
        emailError.value = jsonData['message'] ?? "حدث خطأ ما";
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "خطأ", 
        "فشل الاتصال: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}