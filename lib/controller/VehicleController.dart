import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api_helper.dart';
import '../../services/api_config.dart';
import '../../services/token_service.dart';
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
      print(" loading vehicles");
      isLoading(true);
      String? token = await TokenService.getToken();

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/customer/vehicles"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 1) {
          var data = jsonData['data'] as List;
          vehicleList.value = data
              .map((v) => VehicleModel.fromJson(v))
              .toList();
          print(" Done Found ${vehicleList.length} vehicles.");
        } else {
          print(" Status is 0: ${jsonData['message']}");
        }
      } else {
        print(" Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception in getVehicles: $e");
    } finally {
      isLoading(false);
      print("End of loading.");
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
      print("  add new vehicle...");
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
        print(">>> Added Successfully ");

        Get.snackbar(
          "نجاح",
          "تمت إضافة السيارة بنجاح",
          backgroundColor: Colors.grey[850],
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(15),
          borderRadius: 15,
        );
        getVehicles();
      } else {
        print(" Add failed check validation");

        String errorMsg = jsonData['message'] ?? " مشكلة بالإضافة";

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

        Get.snackbar(
          "تنبيه",
          errorMsg,
          backgroundColor: Colors.grey[900],
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(15),
          borderRadius: 15,
        );
      }
    } catch (e) {
      print(" Catch error in add: $e");
      Get.snackbar(
        "خطأ",
        " خطأ بالاتصال",
        backgroundColor: Colors.grey[900],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // 3. حذف سيارة
  Future<void> deleteVehicle(int id) async {
    try {
      print(" deleting vehicle id: $id");
      isLoading(true);

      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/customer/vehicles/$id",
        {"_method": "DELETE"},
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 || jsonData['status'] == 1) {
        print(">>> Delete Done.");
        vehicleList.removeWhere((v) => v.id == id);

        Get.snackbar(
          "حذف",
          "تم حذف السيارة",
          backgroundColor: Colors.grey[850],
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(15),
          borderRadius: 15,
        );
      } else {
        print("Couldn't delete: ${jsonData['message']}");
        Get.snackbar(
          "خطأ",
          jsonData['message'] ?? "لم ينجح الحذف",
          backgroundColor: Colors.grey[900],
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print(" Catch error in delete: $e");
    } finally {
      isLoading(false);
    }
  }
}
