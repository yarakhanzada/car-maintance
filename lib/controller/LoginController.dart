import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/notification_service.dart';
import 'package:senior_project/view/client/ClientBottombar.dart';
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
    isLoading.value = true;
    clearErrors();

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/login"),
        body: {"email": email, "password": password},
        headers: {"Accept": "application/json"},
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonData["status"] == 1) {
        print(response.body);
        return LoginModel.fromJson(jsonData);
      }

      _handleErrors(jsonData);

      return null;
    } catch (e) {
      _setGeneralError("خطأ في الاتصال بالخادم");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleLogin({
    required String email,
    required String password,
  }) async {
    final result = await login(email: email, password: password);

    if (result == null) return;

    await saveSession(result);
    await NotificationService.getDeviceToken();

    final role = result.data.user.roles.isNotEmpty
        ? result.data.user.roles.first
        : "";

    await TokenService.saveRole(role);
    await TokenService.saveID(result.data.user.id.toString());
    print("SAVED LOGIN ID = ${await TokenService.getID()}");

    _navigateByRole(role);
  }

  void _handleErrors(Map<String, dynamic> jsonData) {
    String message = jsonData["message"] ?? "بيانات الاعتماد غير صحيحة";

    if (jsonData["data"] == null) {
      _setGeneralError(message);
    } else {
      final data = jsonData["data"];

      emailError.value = data["email"]?.first ?? "";
      passwordError.value = data["password"]?.first ?? "";
    }
  }

  void _setGeneralError(String message) {
    emailError.value = message;
    passwordError.value = message;
  }

  void _navigateByRole(String role) {
    switch (role) {
      case "customer":
        Get.offAllNamed("/client");
        break;
      case "towtruck":
        Get.offAllNamed("/driver");
        break;
      case "technician":
        Get.offAllNamed("/tech");
        break;
      default:
        Get.snackbar("خطأ", "دور مستخدم غير معروف");
    }
  }

  Future<void> saveSession(LoginModel model) async {
    await TokenService.saveToken(model.data.accessToken);
    await TokenService.saveRefreshToken(model.data.refreshToken);
  }
}
