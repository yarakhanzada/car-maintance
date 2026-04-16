import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/main.dart';

import 'package:senior_project/services/api_config.dart';

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;
  var emailError = "".obs;

  Future<bool> sendResetCode(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      emailError.value = "Please enter a valid email address";
      return false;
    }

    emailError.value = "";
    isLoading.value = true;

    try {
      var response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/forgot-password"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email}),
      );

      var jsonData = jsonDecode(response.body);
      print("????????????????????");
      print(jsonData);

      if (response.statusCode == 200 && jsonData['status'] == 1) {
        Get.snackbar(
          "Success",
          jsonData['message'],
          backgroundColor: Colors.grey.withOpacity(0.7),
          colorText: Colors.white,
        );
        return true;
      } else {
        emailError.value = jsonData['message'] ?? "Something went wrong";
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
