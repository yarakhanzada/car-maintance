import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:senior_project/view/shared/LoginScreen.dart';
import 'package:senior_project/services/token_service.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  Future<void> logout() async {
    String? token = await TokenService.getToken();

    await TokenService.clearToken();

    Get.offAll(() => LoginScreen());

    if (token != null) {
      try {
        http.post(
          Uri.parse("http://192.168.42.56:8000/api/logout"),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );
      } catch (e) {
        print("Silent logout error: $e");
      }
    }
  }
}
