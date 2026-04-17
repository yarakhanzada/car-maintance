import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/services/api_config.dart';
import '../services/token_service.dart';

class AuthController extends GetxController {
  Future<bool> refreshToken() async {
    try {
      String?refreshToken= await TokenService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      var response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/refresh"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $refreshToken",
        },
      );

      var jsonData = jsonDecode(response.body);
      print("llllllllllllllllllllllllllllllllll");
      print(jsonData)
;
      if (response.statusCode == 200 && jsonData["status"] == 1) {
        if (jsonData["data"] != null &&
            jsonData["data"]["access_token"] != null) {
          await TokenService.saveToken(jsonData["data"]["access_token"]);

          print(" Success: New Access Token received!");
          return true;
        }
      }

      print(" Refresh Failed: ${jsonData['message']}");
      return false;
    } catch (e) {
      print(" Refresh Error: $e");
      return false;
    }
  }
}
