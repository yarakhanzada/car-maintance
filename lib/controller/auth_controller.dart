import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/services/api_config.dart';

import '../services/token_service.dart';

class AuthController extends GetxController {
  Future<bool> refreshToken() async {
    print("[Refresh] بدء تحديث التوكن");

    try {
      final refreshToken = await TokenService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        print("[Refresh] لا يوجد Refresh Token");
        return false;
      }

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/refresh"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $refreshToken",
        },
      );

      print("[Refresh] Status: ${response.statusCode}");
      print("[Refresh] Body: ${response.body}");

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          jsonData["status"] == 1 &&
          jsonData["data"] != null) {
        final data = jsonData["data"];

        final newAccessToken = data["access_token"];
        final newRefreshToken = data["refresh_token"];

        if (newAccessToken == null ||
            newAccessToken.toString().isEmpty) {
          print("[Refresh] Access Token غير موجود");
          return false;
        }

        await TokenService.saveToken(
          newAccessToken.toString(),
        );

        if (newRefreshToken != null &&
            newRefreshToken.toString().isNotEmpty) {
          await TokenService.saveRefreshToken(
            newRefreshToken.toString(),
          );
        }

        print("[Refresh] تم تحديث التوكنات بنجاح");

        return true;
      }

      print("[Refresh] فشل تحديث التوكن");
      return false;
    } catch (e) {
      print("[Refresh] Exception: $e");
      return false;
    }
  }
}