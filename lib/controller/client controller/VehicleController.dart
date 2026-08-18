import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../services/api_helper.dart';
import '../../../services/api_config.dart';
import '../../../model/VehicleModel.dart';

class VehicleController extends GetxController {
  var isLoading = true.obs;
  var vehicleList = <VehicleModel>[].obs;
  var selectedVehicleId = RxnInt();

  @override
  void onInit() {
    getVehicles();
    _loadSelectedVehicle();
    super.onInit();
  }

  void selectVehicle(int id) async {
    selectedVehicleId.value = id;
    print(" Selected Vehicle ID : $id");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_vehicle_id', id);

    _showSnackBar(
      "Selected Vehicle",
      "Selected Vehicle ID: $id",
      Colors.grey[850]!,
    );
  }

  void _loadSelectedVehicle() async {
    final prefs = await SharedPreferences.getInstance();
    int? storedId = prefs.getInt('selected_vehicle_id');
    if (storedId != null) {
      selectedVehicleId.value = storedId;
    }
  }

  // 1. Display vehicles
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

  // 2. Add a vehicle
  Future<void> addVehicle({
    required String brand,
    required String model,
    required String year,
    required String plate,
  }) async {
    try {
      isLoading(true);

      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/customer/vehicles",
        {"brand": brand, "model": model, "year": year, "plate_number": plate},
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

  // 3. Delete a vehicle
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
        if (v is List) {
          details.addAll(v.map((e) => e.toString()));
        } else {
          details.add(v.toString());
        }
      });
      if (details.isNotEmpty) errorMsg = details.join("\n");
    }
    _showSnackBar("تنبيه", errorMsg, Colors.grey[900]!);
  }
}
