import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/services/location_service.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';
import 'package:senior_project/services/token_service.dart';
import 'package:senior_project/view/client/ClientBottombar.dart';
import 'package:senior_project/view/client/TowingRequestScreen.dart';
import 'package:senior_project/controller/client%20controller/VehicleController.dart';

class TowingController extends GetxController {
  var isLoading = false.obs;
  var selectedVehicleId = RxnInt();
  final problemController = TextEditingController();
  final RxList<XFile> images = <XFile>[].obs;

  final VehicleController _vehicleCtrl = Get.find<VehicleController>();
  List get userVehicles => _vehicleCtrl.vehicleList;
  void printFullResponse(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<void> sendTowingRequest() async {
    if (selectedVehicleId.value == null) {
      Get.snackbar("Warning", "Please select a vehicle first");
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLoading.value = false;
        Get.snackbar("تحذير", "من فضلك فعل خدمات الموقع لإرسال طلب السحب");
        return;
      }

      var position = await LocationService.getCurrentLocation();
      if (position == null) {
        isLoading.value = false;
        Get.snackbar("Error", "لم نتمكن من تحديد موقعك");
        return;
      }

      Map<String, dynamic> body = {
        "vehicles_id": selectedVehicleId.value.toString(),
        "latitude": position.latitude.toString(),
        "longitude": position.longitude.toString(),
        "problem_type": problemController.text.isEmpty
            ? "Towing Request"
            : problemController.text,
      };

      final url = "${ApiConfig.baseUrl}/requests/towing";
      var response = await ApiHelper.postWithImages(url, body, images);

      var data = jsonDecode(response.body);

      print("------- TOWING DEBUG START -------");
      print("Status: ${response.statusCode}");
      printFullResponse(response.body);
      print("------- TOWING DEBUG END ---------");

      if (response.statusCode == 200 || response.statusCode == 201) {
        resetForm();
        final requestData = data['data'];
        requestData['user_id'] = await TokenService.getID();
        print("Saved Request ID: ${requestData['service_request']['id']}");
        await TokenService.saveActiveRequest(jsonEncode(requestData));
        Get.off(() => RequestTrackingScreen(requestData: data['data']));
      } else {
        String errorMsg = data['message'] ?? "فشل إرسال الطلب";
        Get.snackbar("Error", errorMsg);
      }
    } catch (e) {
      print("Towing Catch Error: $e");
      Get.snackbar("Error", "حدث خطأ غير متوقع: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    selectedVehicleId.value = null;
    problemController.clear();
    images.clear();
  }

  void goToGarageToAddVehicle() {
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().selectedIndex.value = 3;
    }
    Get.back();
  }
}
