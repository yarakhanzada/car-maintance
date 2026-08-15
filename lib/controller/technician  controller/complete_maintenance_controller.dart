import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/view/Technician/TechnicianBottombar.dart';
import '../../services/api_helper.dart';

class CompleteMaintenanceController extends GetxController {
  var isLoading = false.obs;
  final TextEditingController notesController = TextEditingController();

  var beforeImages = <XFile>[].obs;
  var afterImages = <XFile>[].obs;
  Future<bool> completeTask({required String taskId}) async {
    String notes = notesController.text.trim();

    // if (notes.isEmpty) {
    //   Get.snackbar("تنبيه", "الرجاء كتابة ملاحظات الصيانة قبل الإغلاق");
    //   return false;
    // }

    try {
      isLoading(true);
      String url =
          "${ApiConfig.baseUrl}/v1/technician/maintenance-tasks/$taskId/complete";
          Map<String, String> body = {"notes": notes};

      final response = await ApiHelper.postMaintenanceComplete(
        url,
        body,
        beforeImages,
        afterImages,
      );
      // --- إضافة طباعة لحالة الاستجابة ---
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
    if (responseData['status'] == 1) {
  Get.snackbar(
    "تمت العملية",
    responseData['message'] ?? "اكتملت الصيانة بنجاح.",
  );

  notesController.clear();
  beforeImages.clear();
  afterImages.clear();

  return true;
} else {
          Get.snackbar(
            "تنبيه",
            responseData['message'] ?? "تعذر إكمال الصيانة.",
          );
          return false; // فشل
        }
      }
      return false; // فشل
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ أثناء الإرسال: $e");
      return false; // فشل
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
