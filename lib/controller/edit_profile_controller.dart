import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/auth_controller.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final user = Get.arguments;
    if (user != null) {
      nameController.text = user.name ?? "";
      emailController.text = user.email ?? "";
      phoneController.text = user.phone ?? "";
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      final response = await ApiHelper.put("${ApiConfig.baseUrl}/profile", {
        "name": nameController.text,
        "phone": phoneController.text,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == 1) {
        Get.back(result: true);
        _showSnackBar("Success", data["message"], Colors.grey[850]!);
      } else {
        _showSnackBar(
          "Error",
          data["message"] ?? "Update failed",
          Colors.grey[850]!,
        );
      }
    } catch (e) {
      _showSnackBar("Error", "Something went wrong", Colors.grey[850]!);
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackBar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
