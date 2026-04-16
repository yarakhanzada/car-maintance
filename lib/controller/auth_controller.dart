import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/services/api_config.dart';
import '../services/token_service.dart';

class AuthController extends GetxController {
  Future<bool> refreshToken() async {
    try {
      String? refresh = await TokenService.getRefreshToken();

      if (refresh == null) return false;

      var response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/refresh"),
        body: {"refresh_token": refresh},
      );

      var jsonData = jsonDecode(response.body);

      if (jsonData["status"] == 1) {
        await TokenService.saveToken(jsonData["data"]["access_token"]);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
