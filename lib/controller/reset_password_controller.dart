import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/view/shared/LoginScreen.dart';

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
        "Error",
        "Passwords do not match",
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    try {
      isLoading.value = true;
      print("--- [DEBUG: Reset Password Request] ---");
      print("Email: '$email'");
      print("Code: '$code'");
      print("Password: '$password'");
      print("Confirm: '$confirmPassword'");
      print(
        "Payload JSON: ${jsonEncode({"email": email.trim(), "code": code.trim(), "password": password, "password_confirmation": confirmPassword})}",
      );
      print("---------------------------------------");
      var response = await http.post(
        Uri.parse("http://192.168.1.2:8000/api/reset-password"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email.trim(),
          "code": code.trim(),
          "password": password,
          "password_confirmation": confirmPassword,
        }),
      );

      var jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        Get.snackbar(
          "Success",
          jsonData['message'],
          backgroundColor: Colors.grey,
        );
        Get.offAll(() => LoginScreen());
      } else {
        Get.snackbar(
          "Error",
          jsonData['message'] ?? "Reset failed",
          backgroundColor: Colors.redAccent,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed");
    } finally {
      isLoading.value = false;
    }
  }
}
