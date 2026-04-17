import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/main.dart';
import '../model/signup_model.dart';

import 'package:senior_project/services/api_config.dart';

import '../services/api_helper.dart';
class SignUpController extends GetxController {
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;

  var passwordErrors = <String>[].obs;

  var emailError = "".obs;
  var phoneError = "".obs;
  var generalError = "".obs;

  var confirmPasswordError = "".obs;

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;

  void toggleConfirmPassword() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

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

var response = await ApiHelper.post(
  "${ApiConfig.baseUrl}/register",
  {
    "name": name,
    "email": email,
    "phone": phone,
    "password": password,
    "password_confirmation": confirmPassword,
  },
  skipAuth: true,
);
     
      var jsonData = jsonDecode(response.body);
      print("?????????????????????????????????n");
      print(jsonData);
   
   if (jsonData["status"] == 1) {
  return SignUpModel.fromJson(jsonData);
}

      if (jsonData["status"] == 0) {
        generalError.value = jsonData["message"];

        if (jsonData["data"] != null) {
          if (jsonData["data"]["password"] != null) {
            passwordErrors.value = List<String>.from(
              jsonData["data"]["password"],
            );
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

  void validatePasswordLive(String value) {
    List<String> errors = [];

    if (value.isEmpty) {
      passwordErrors.value = [];
      return;
    }

    if (value.length < 8) {
      errors.add("The password field must be at least 8 characters.");
    }

    if (!value.contains(RegExp(r'[A-Z]')) ||
        !value.contains(RegExp(r'[a-z]'))) {
      errors.add(
        "The password field must contain at least one uppercase and one lowercase letter.",
      );
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add("The password field must contain at least one symbol.");
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      errors.add("The password field must contain at least one number.");
    }

    passwordErrors.assignAll(errors);
  }
}
