import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/view/Technician/NewTasksScreen.dart';
import '../../services/api_helper.dart';

class CompleteMaintenanceController extends GetxController {
  var isLoading = false.obs;
  final TextEditingController notesController = TextEditingController();

  Future<void> completeTask({required String taskId}) async {
    String notes = notesController.text.trim();

    if (notes.isEmpty) {
      Get.snackbar(
        "تنبيه",
        "الرجاء كتابة تقرير أو ملاحظات الصيانة قبل الإغلاق",
      );
      return;
    }

    try {
      isLoading(true);

      String url =
          "${ApiConfig.baseUrl}/v1/technician/maintenance-tasks/$taskId/complete";

      Map<String, dynamic> body = {"notes": notes};

      final response = await ApiHelper.post(url, body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 1) {
          Get.snackbar(
            "تمت العملية",
            responseData['message'] ?? "اكتملت الصيانة بنجاح.",
            snackPosition: SnackPosition.BOTTOM,
          );

          notesController.clear();

          Get.offAll(() => const NewTasksScreen());
        } else {
          Get.snackbar(
            "تنبيه من النظام",
            responseData['message'] ?? "تعذر إكمال الصيانة.",
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        }
      } else {
        Get.snackbar(
          "خطأ",
          "فشل الاتصال بالسيرفر. رمز الحالة: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ أثناء إرسال طلب الإنهاء: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
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
