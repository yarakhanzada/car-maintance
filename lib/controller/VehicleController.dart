import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../services/api_helper.dart';
import '../../services/api_config.dart';
import '../../model/VehicleModel.dart';

class VehicleController extends GetxController {
  var isLoading = true.obs;
  var vehicleList = <VehicleModel>[].obs;

  @override
  void onInit() {
    getVehicles();
    super.onInit();
  }

  // 1. عرض السيارات
  Future<void> getVehicles() async {
    try {
      isLoading(true);

      final response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/customer/vehicles",
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 1) {
          var data = jsonData['data'] as List;
          vehicleList.value = data
              .map((v) => VehicleModel.fromJson(v))
              .toList();
        }
      } else {
        print("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception in getVehicles: $e");
    } finally {
      isLoading(false);
    }
  }

  // 2. إضافة سيارة
  Future<void> addVehicle({
    required String brand,
    required String model,
    required String year,
    required String chassis,
  }) async {
    try {
      isLoading(true);

      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/customer/vehicles",
        {
          "brand": brand,
          "model": model,
          "year": year,
          "chassis_number": chassis,
        },
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 || jsonData['status'] == 1) {
        _showSnackBar("نجاح", "تمت إضافة السيارة بنجاح", Colors.grey[850]!);
        getVehicles();
      } else {
        _handleApiError(jsonData);
      }
    } catch (e) {
      _showSnackBar("خطأ", "خطأ بالاتصال", Colors.grey[900]!);
    } finally {
      isLoading(false);
    }
  }

  // 3. حذف سيارة
  Future<void> deleteVehicle(int id) async {
    try {
      isLoading(true);

      final response = await ApiHelper.delete(
        "${ApiConfig.baseUrl}/customer/vehicles/$id",
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 || jsonData['status'] == 1) {
        vehicleList.removeWhere((v) => v.id == id);
        _showSnackBar("حذف", "تم حذف السيارة", Colors.grey[850]!);
      } else {
        _showSnackBar(
          "خطأ",
          jsonData['message'] ?? "لم ينجح الحذف",
          Colors.grey[900]!,
        );
      }
    } catch (e) {
      print("Catch error in delete: $e");
    } finally {
      isLoading(false);
    }
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
    );
  }

  void _handleApiError(Map<String, dynamic> jsonData) {
    String errorMsg = jsonData['message'] ?? "مشكلة في العملية";
    if (jsonData['data'] != null && jsonData['data'] is Map) {
      Map<String, dynamic> errors = jsonData['data'];
      List<String> details = [];
      errors.forEach((k, v) {
        if (v is List)
          details.addAll(v.map((e) => e.toString()));
        else
          details.add(v.toString());
      });
      if (details.isNotEmpty) errorMsg = details.join("\n");
    }
    _showSnackBar("تنبيه", errorMsg, Colors.grey[900]!);
  }
}
