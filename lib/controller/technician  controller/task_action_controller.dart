import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senior_project/controller/technician%20%20controller/taskcontroller.dart';
import 'package:senior_project/view/Technician/TechNavigationController.dart';
import '../../services/api_config.dart';
import '../../services/api_helper.dart';
import 'technician_tasks_controller.dart';

class TaskActionController extends GetxController {
  var isStarting = false.obs;
  var isRejecting = false.obs;

  // 1. (Start Task)
  Future<void> startTask(int taskId) async {
    try {
      isStarting.value = true;
      _showLoadingDialog("Starting mission...");

      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/v1/technician/maintenance-tasks/$taskId/start",
        {},
      );

      print("============== START TASK RESPONSE ==============");
      print("Status Code: ${response?.statusCode}");

      if (response?.body != null) {
        try {
          var jsonResponse = jsonDecode(response!.body);
          var prettyJson = const JsonEncoder.withIndent(
            '  ',
          ).convert(jsonResponse);
          print("Response Body:\n$prettyJson");
        } catch (e) {
          print("Response Body (Raw): ${response?.body}");
        }
      } else {
        print("Response Body: [Empty]");
      }
      print("=================================================");

      if (Get.isDialogOpen == true) {
        Get.back();
      }
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        var responseData = jsonDecode(response.body);
        var taskData = responseData['data'];

        if (Get.isRegistered<TechnicianTasksController>()) {
          Get.find<TechnicianTasksController>().fetchTechnicianTasks();
        }

        final taskController = Get.find<TaskController>();
        taskController.setTask(taskData);

        final bottomBarController = Get.find<TechNavigationController>();
        bottomBarController.selectedIndex.value = 1;

        Get.back();
        Get.snackbar("Mission Started", "The task status has been updated.");
      } else {
        String errorMessage = "حدث خطأ غير معروف";
        try {
          var errorData = jsonDecode(response!.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}

        Get.snackbar("خطأ", errorMessage);
      }
    } catch (e) {
      Get.back();
      print("خطا: $e");
      Get.snackbar("خطأ", "حدث خطأ: $e");
    } finally {
      isStarting.value = false;
    }
  }

  // 2. (Reject Task)
  Future<void> rejectTask(int taskId, String reason) async {
    if (reason.trim().isEmpty) {
      Get.snackbar("تحذير", "يرجى تقديم سبب لرفض المهمة.");
      return;
    }

    try {
      isRejecting.value = true;
      _showLoadingDialog("Submitting rejection...");

      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/v1/technician/maintenance-tasks/$taskId/reject",
        {"reason": reason},
      );

      print("============== REJECT TASK RESPONSE ==============");
      print("Status Code: ${response?.statusCode}");
      print("Response Body: ${response?.body}");
      print("==================================================");

      Get.back();

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (Get.isRegistered<TechnicianTasksController>()) {
          Get.find<TechnicianTasksController>().fetchTechnicianTasks();
        }

        Get.close(2);

        Get.snackbar(
          "المهمة مرفوضة",
          "تم رفض المهمة بنجاح.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          icon: const Icon(Icons.close_rounded, color: Colors.red),
        );
      }
    } catch (e) {
      Get.back();
      print(" Error in rejectTask Catch: $e");
      Get.snackbar("خطأ", "فشل في رفض المهمة: $e");
    } finally {
      isRejecting.value = false;
    }
  }

  void _showLoadingDialog(String message) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.staggeredDotsWave(
                  color: const Color(0xFFE55757),
                  size: 50,
                ),
                const SizedBox(height: 15),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
