import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;

  var emailError = "".obs;     // 👈 خطأ الإيميل
  var generalError = "".obs;   // 👈 خطأ عام

  void clearErrors() {
    emailError.value = "";
    generalError.value = "";
  }

  Future<bool> sendResetCode(String email) async {
    try {
      isLoading.value = true;
      clearErrors();

      print("🚀 FORGOT PASSWORD START");
      print("📦 EMAIL: $email");

      final response = await http.post(
        Uri.parse("http://192.168.1.2:8000/api/forgot-password"),
        body: {"email": email},
        headers: {
          "Accept": "application/json",
        },
      );

      print("📥 STATUS CODE: ${response.statusCode}");
      print("📥 RESPONSE BODY: ${response.body}");

      final jsonData = jsonDecode(response.body);

      print("📊 PARSED JSON: $jsonData");

      // ✅ نجاح
      if (response.statusCode == 200 && jsonData["status"] == 1) {
        print("✅ SUCCESS");
        return true;
      }

      // ❌ خطأ API
      print("❌ FAILED REQUEST");

      // 🔴 رسالة عامة
      generalError.value = jsonData["message"] ?? "Error";

      // 🔴 أخطاء الحقول
      if (jsonData["errors"] != null) {
        if (jsonData["errors"]["email"] != null) {
          emailError.value = jsonData["errors"]["email"][0];
        }
      }

      return false;
    } catch (e) {
      print("🔥 EXCEPTION: $e");
      generalError.value = "Server error";
      return false;
    } finally {
      isLoading.value = false;
      print("🏁 REQUEST FINISHED");
    }
  }
}