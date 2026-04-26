import 'dart:convert';
import 'package:get/get.dart';
import 'package:senior_project/services/api_config.dart';
import '../services/api_helper.dart';

class FcmController extends GetxController {
  Future<void> updateDeviceToken(String fcmToken) async {
    try {
      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/update-fcm-token",
        {"fcm_token": fcmToken},
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message = responseData['message'] ?? "No message provided";

      if (response.statusCode == 200 && responseData['status'] == 1) {
        print(" Success: $message");
      } else {
        print(" Failed: $message");
      }
    } catch (e) {
      print(" Error FcmController: $e");
    }
  }
}
