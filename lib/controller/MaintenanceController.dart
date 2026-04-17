import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../services/api_helper.dart';
import '../../services/api_config.dart';

class MaintenanceController extends GetxController {
  var isLoading = false.obs;

  final problemController = TextEditingController();
  final dateController = TextEditingController();

  void clearFields() {
    problemController.clear();
    dateController.clear();
  }

  Future<void> sendMaintenanceRequest({
    required int vehicleId,
    required String maintenanceType, // "immediate" أو "scheduled"
    String? scheduledDate,
    required String problemType,
  }) async {
    try {
      isLoading(true);

      Map<String, dynamic> body = {
        "vehicles_id": vehicleId,
        "maintenance_type": maintenanceType,
        "problem_type": problemType,
      };

      if (maintenanceType == "scheduled" && scheduledDate != null) {
        body["scheduled_date"] = scheduledDate;
      }

      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/requests/maintenance",
        body,
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 || jsonData['status'] == 1) {
        print("lllllllllllllllllllllllllll");
        String successMessage =
            jsonData['message'] ?? "Request created successfully";

        clearFields();

        _showSnackBar("Success", successMessage, Colors.grey[850]!);
      } else {
        _handleApiError(jsonData);
      }
    } catch (e) {
      print("Error in Maintenance Request: $e");
      _showSnackBar("Error", " خطأ  ", Colors.red[900]!);
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    problemController.dispose();
    dateController.dispose();
    super.onClose();
  }

  void _showSnackBar(String title, String message, Color bgColor) {
    Get.snackbar(
      title,
      message,
      backgroundColor: bgColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      duration: const Duration(seconds: 3),
    );
  }

  void _handleApiError(Map<String, dynamic> jsonData) {
    String errorMsg = jsonData['message'] ?? "فشلت العملية";

    if (jsonData['data'] != null && jsonData['data'] is Map) {
      Map<String, dynamic> errors = jsonData['data'];
      List<String> details = [];

      errors.forEach((key, value) {
        if (value is List) {
          details.addAll(value.map((e) => e.toString()));
        } else {
          details.add(value.toString());
        }
      });

      if (details.isNotEmpty) {
        errorMsg = details.join("\n");
      }
    }

    _showSnackBar("Alert", errorMsg, Colors.grey[900]!);
  }
}
