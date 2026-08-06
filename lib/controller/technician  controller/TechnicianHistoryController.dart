import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:senior_project/model/technician%20model/TechnicianHistoryModel.dart';
import 'dart:convert';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';

class TechnicianHistoryController extends GetxController {
  var isLoading = false.obs;
  var historyTasks = <HistoryTask>[].obs;

  @override
  void onInit() {
    fetchHistoryTasks();
    super.onInit();
  }

  Future<void> fetchHistoryTasks() async {
    isLoading.value = true;
    try {
      String url =
          "${ApiConfig.baseUrl}/v1/technician/maintenance-tasks/history";

      final response = await ApiHelper.get(url);
      print("========== RESPONSE ==========");
print("STATUS CODE: ${response.statusCode}");
print("BODY:");
const JsonEncoder encoder = JsonEncoder.withIndent('  ');
debugPrint(
  encoder.convert(jsonDecode(response.body)),
  wrapWidth: 4096,
);

print("==============================");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['status'] == 1) {
          final historyModel = TechnicianHistoryModel.fromJson(jsonData);
          historyTasks.assignAll(historyModel.data);
          print(" تم تحميل السجل بنجاح، عدد المهام: ${historyTasks.length}");
        } else {
          Get.snackbar("تنبيه", jsonData['message'] ?? "فشل في جلب البيانات");
        }
      } else {
        Get.snackbar("خطأ", "فشل الاتصال بالسيرفر: ${response.statusCode}");
      }
    } catch (e) {
      print(" Error Fetching History: $e");
      Get.snackbar("خطأ", "حدث خطأ غير متوقع أثناء تحميل السجل");
    } finally {
      isLoading.value = false;
    }
  }
  
}
