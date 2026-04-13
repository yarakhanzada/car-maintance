import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/view/client/ClientBottombar.dart';
import 'package:senior_project/view/shared/reset_password_screen.dart';

class OTPController extends GetxController {
  var isLoading = false.obs;
  List<String> otpCodes = List.filled(6, "");
  var isResending = false.obs;
  Timer? _timer;
  var secondsRemaining = 59.obs;
  var enableResend = false.obs;
  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    otpCodes = List.filled(6, "");
    _timer?.cancel();
    secondsRemaining.value = 59;
    enableResend.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        enableResend.value = true;
        _timer?.cancel();
      }
    });
  }

  Future<void> resendCode(String email) async {
    try {
      isResending.value = true;
      var response = await http.post(
        Uri.parse("http://192.168.42.56:8000/api/resend-code"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email}),
      );

      var jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 1) {
        Get.snackbar(
          "Success",
          jsonData['message'],
          backgroundColor: Colors.grey.withOpacity(0.5),
          colorText: Colors.white,
        );
        startTimer();
      } else {
        Get.snackbar(
          "Error",
          jsonData['message'],
          backgroundColor: Colors.redAccent.withOpacity(0.5),
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Check your connection");
    } finally {
      isResending.value = false;
    }
  }

  Future<void> verifyOTP(String email, String type) async {
    String fullCode = otpCodes.join("");

    if (fullCode.length < 6) {
      Get.snackbar(
        "Error",
        "Please enter full code",
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    if (type == "reset") {
      Get.to(
        () => ResetPasswordScreen(),
        arguments: {"email": email, "code": fullCode},
      );
      return;
    }

    try {
      isLoading.value = true;
      var response = await http.post(
        Uri.parse("http://192.168.42.56:8000/api/verify"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email, "code": fullCode}),
      );

      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 1) {
        Get.snackbar(
          "Success",
          jsonData['message'],
          backgroundColor: Colors.grey,
        );
        Get.offAll(() => ClientBottombar());
      } else {
        Get.snackbar(
          "Failed",
          jsonData['message'] ?? "Wrong code",
          backgroundColor: Colors.redAccent,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  String get formattedTime {
    int minutes = secondsRemaining.value ~/ 60;
    int seconds = secondsRemaining.value % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }
}
