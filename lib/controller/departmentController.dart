import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/model/department_model.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';

class DepartmentController extends GetxController {
  var departments = <Department>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchDepartments();
    super.onInit();
  }

  Future<void> fetchDepartments() async {
    try {
      isLoading.value = true;

      final response = await ApiHelper.get("${ApiConfig.baseUrl}/customer/departments");
      final data = jsonDecode(response.body);
    
      if (response.statusCode == 200 && data['status'] == 1) {
        List<dynamic> departmentsData = data['data'];
        departments.assignAll(
          departmentsData.map((e) => Department.fromJson(e)).toList()
        );
      } 
    } catch (e) {
      _showSnackBar(
        "Error",
        "Something went wrong",
        Colors.grey[850]!,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackBar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 3),
    );
  }
}