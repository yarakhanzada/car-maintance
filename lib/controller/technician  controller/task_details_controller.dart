import 'package:get/get.dart';
import 'package:senior_project/services/api_config.dart';
import 'dart:convert';
import '../../model/technician model/task_details_model.dart';
import '../../services/api_helper.dart';

class TaskDetailsController extends GetxController {
  var isLoadingDetails = false.obs;
  var taskDetails = Rxn<MaintenanceTaskDetails>();

  Future<void> fetchTaskDetails(int taskId) async {
    try {
      isLoadingDetails(true);
      taskDetails.value = null;

      String url =
          "${ApiConfig.baseUrl}/v1/technician/maintenance-tasks/$taskId";

      final response = await ApiHelper.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        final taskResponse = TaskDetailsResponse.fromJson(decodedData);

        if (taskResponse.status == 1) {
          taskDetails.value = taskResponse.data;
        } else {
          Get.snackbar("تنبيه", taskResponse.message);
          print("⚠️ [TaskDetailsController]: ${taskResponse.message}");
        }
      } else {
        Get.snackbar("خطأ", "فشل الاتصال بالسيرفر: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      Get.snackbar("خطأ في الاتصال", "حدث خطأ غير متوقع: $e");
      print("🔥 [TaskDetailsController]: حدث خطأ غير متوقع: $e");
      print(
        "StackTrace: $stackTrace",
      ); // هذا سيخبرنا بالضبط أي سطر في الموديل هو المسبب
    } finally {
      isLoadingDetails(false);
    }
  }
}
