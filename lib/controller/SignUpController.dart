import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/signup_model.dart';

class SignUpController extends GetxController {
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;

  var passwordErrors = <String>[].obs;

  var emailError = "".obs;
  var phoneError = "".obs;
  var generalError = "".obs;

  var confirmPasswordError = "".obs;

  void togglePassword() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  void toggleConfirmPassword() =>
      isConfirmPasswordHidden.value =
          !isConfirmPasswordHidden.value;

  Future<SignUpModel?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;

      passwordErrors.clear();
      emailError.value = "";
      phoneError.value = "";
      generalError.value = "";
      confirmPasswordError.value = "";

      if (password != confirmPassword) {
        confirmPasswordError.value = "Passwords do not match";
        return null;
      }

      var response = await http.post(
        Uri.parse("http://192.168.1.2:8000/api/register"),
        body: {
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "password_confirmation": confirmPassword,
        },
             headers: {
          "Accept": "application/json", 
        },
      );

      var jsonData = jsonDecode(response.body);

      if (jsonData["status"] == 1) {
        return SignUpModel.fromJson(jsonData);
      }

      if (jsonData["status"] == 0) {
        generalError.value = jsonData["message"];

        if (jsonData["data"] != null) {
          if (jsonData["data"]["password"] != null) {
            passwordErrors.value =
                List<String>.from(jsonData["data"]["password"]);
          }

          if (jsonData["data"]["email"] != null) {
            emailError.value = jsonData["data"]["email"][0];
          }

          if (jsonData["data"]["phone"] != null) {
            phoneError.value = jsonData["data"]["phone"][0];
          }
        }

        return null;
      }

      return null;
    } catch (e) {
      generalError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}