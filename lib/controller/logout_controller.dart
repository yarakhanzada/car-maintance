import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/main.dart';
import 'dart:convert';
import 'package:senior_project/view/shared/LoginScreen.dart';
import 'package:senior_project/services/token_service.dart';

import 'package:senior_project/services/api_config.dart';

import '../services/api_helper.dart';

class LogoutController extends GetxController {
  var isLoading = false.obs;

  Future<void> logout() async {
    isLoading.value = true;

    String? token = await TokenService.getToken();

    await TokenService.clearToken();

    Get.offAllNamed('/ww');

    try {
      if (token != null && token.isNotEmpty) {
        await ApiHelper.post(
          "${ApiConfig.baseUrl}/logout",
          {},
        );
      }
    } catch (e) {
      print("Silent logout error: $e");
    }

    isLoading.value = false;
  }
}