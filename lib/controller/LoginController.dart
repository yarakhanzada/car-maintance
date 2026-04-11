import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/login_model.dart';
import '../services/token_service.dart';

class LoginController extends GetxController {
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  var emailError = "".obs;
  var passwordError = "".obs;

  void clearErrors() {
    emailError.value = "";
    passwordError.value = "";
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<LoginModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      clearErrors();

      print(" LOGIN START");

      final response = await http.post(
        Uri.parse("http://192.168.42.56:8000/api/login"),
        body: {"email": email, "password": password},
        headers: {"Accept": "application/json"},
      );

      print(" STATUS: ${response.statusCode}");
      print(" BODY: ${response.body}");

      final jsonData = jsonDecode(response.body);

      print(" PARSED: $jsonData");

      if (jsonData["status"] == 1) {
        print(" LOGIN SUCCESS");
        return LoginModel.fromJson(jsonData);
      }

      print(" LOGIN FAILED");

      String message = jsonData["message"] ?? "Invalid credentials";

      if (jsonData["data"] == null) {
        emailError.value = message;
        passwordError.value = message;
      } else {
        final data = jsonData["data"];

        if (data["email"] != null) {
          emailError.value = data["email"][0];
        }

        if (data["password"] != null) {
          passwordError.value = data["password"][0];
        }
      }

      return null;
    } finally {
      isLoading.value = false;
      print(" DONE");
    }
  }

  Future<void> saveSession(LoginModel model) async {
    await TokenService.saveToken(model.data.accessToken);
    await TokenService.saveRefreshToken(model.data.refreshToken);
  }
}
