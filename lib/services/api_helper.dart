import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_service.dart';
import '../controller/auth_controller.dart';

class ApiHelper {
  static Future<http.Response> post(
    String url,
    Map<String, String> body,
  ) async {
    String? token = await TokenService.getToken();

    var response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 401) {
      bool refreshed = await AuthController().refreshToken();

      if (refreshed) {
        String? newToken = await TokenService.getToken();

        return await http.post(
          Uri.parse(url),
          body: body,
          headers: {
            "Authorization": "Bearer $newToken",
          },
        );
      }
    }

    return response;
  }
}