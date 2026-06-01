import 'dart:convert';
import 'package:get/get.dart';
import 'package:senior_project/model/technician%20model/maintenance_task_model.dart';
import 'package:senior_project/services/api_config.dart';
import '../../services/api_helper.dart';

class TechnicianTasksController extends GetxController {
  var isLoading = false.obs;
  var taskList = <MaintenanceTask>[].obs;

  @override
  void onInit() {
    fetchTechnicianTasks();
    super.onInit();
  }

  Future<void> fetchTechnicianTasks() async {
    try {
      isLoading(true);

      String url = "${ApiConfig.baseUrl}/v1/technician/maintenance-tasks";

      final response = await ApiHelper.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        print(decodedData);

        if (decodedData['status'] == 1) {
          final taskResponse = MaintenanceTaskResponse.fromJson(decodedData);
          taskList.assignAll(taskResponse.data);
        } else {
          Get.snackbar(
            "تنبيه",
            decodedData['message'] ?? "فشل تحميل المهام",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          Get.snackbar(
            "فشل العملية",
            errorData['message'] ?? "حدث خطأ في السيرفر",
          );
        } catch (_) {
          Get.snackbar("خطأ", "فشل الاتصال بالسيرفر: ${response.statusCode}");
        }
      }
    } catch (e) {
      print(" Error fetching technician tasks: $e");
      Get.snackbar("خطأ", "حدث خطأ أثناء معالجة البيانات");
    } finally {
      isLoading(false);
    }
  }
}
