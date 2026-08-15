import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:senior_project/services/token_service.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/token_service.dart';
import '../controller/auth_controller.dart';


class Midlecontroller extends GetxController {
  Future<void> checkLogin() async {
    try {
      final token = await TokenService.getToken();
      final refreshToken = await TokenService.getRefreshToken();
      final role = await TokenService.getRole();

      print("[Auth] Access Token موجود: ${token != null}");
      print("[Auth] Refresh Token موجود: ${refreshToken != null}");
      print("[Auth] Role: $role");

      if (token == null || token.isEmpty) {
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshed = await _refreshToken();

          if (!refreshed) {
            await _logout();
            return;
          }
        } else {
          await _logout();
          return;
        }
      } else {
        final expired = _isTokenExpired(token);

        if (expired) {
          if (refreshToken == null || refreshToken.isEmpty) {
            await _logout();
            return;
          }

          final refreshed = await _refreshToken();

          if (!refreshed) {
            await _logout();
            return;
          }
        }
      }

      final currentRole = await TokenService.getRole();

      if (currentRole == "customer") {
        Get.offAllNamed("/client");
      } else if (currentRole == "towtruck") {
        Get.offAllNamed("/driver");
      } else if (currentRole == "technician") {
        Get.offAllNamed("/tech");
      } else {
        await _logout();
      }
    } catch (e) {
      print("[Auth] checkLogin Exception: $e");
      await _logout();
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final authController = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : Get.put(AuthController(), permanent: true);

      return await authController.refreshToken();
    } catch (e) {
      print("[Auth] Refresh Exception: $e");
      return false;
    }
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return true;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);

      final payloadMap = jsonDecode(
        utf8.decode(base64Url.decode(normalized)),
      );

      final exp = payloadMap['exp'];

      if (exp == null) {
        return true;
      }

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(
        (exp as num).toInt() * 1000,
      );

      return DateTime.now()
          .add(const Duration(minutes: 1))
          .isAfter(expiryDate);
    } catch (e) {
      print("[Auth] Token expiry error: $e");
      return true;
    }
  }

  Future<void> _logout() async {
    await TokenService.clearSessionData();
    Get.offAllNamed("/ww");
  }
}