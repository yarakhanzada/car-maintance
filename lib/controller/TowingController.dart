import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:senior_project/services/location_service.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';
import 'package:senior_project/view/client/TowingRequestScreen.dart';
import 'package:senior_project/controller/VehicleController.dart';

class TowingController extends GetxController {
  var isLoading = false.obs;

  Future<void> sendTowingRequest() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();

        isLoading.value = false;
        Get.snackbar("تنبيه", "يرجى تفعيل الموقع ثم الضغط على الزر مرة أخرى");
        return;
      }

      var position = await LocationService.getCurrentLocation();

      if (position == null) {
        isLoading.value = false;
        Get.snackbar("خطأ", "لم نتمكن من تحديد موقعك");
        return;
      }

      final vehicleId = Get.find<VehicleController>().selectedVehicleId.value;

      Map<String, dynamic> body = {
        "vehicles_id": vehicleId,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "problem_type": "Towing Request",
      };

      var response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/requests/towing",
        body,
      );
      var data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.to(() => RequestTrackingScreen(requestData: data['data']));
        print(
          "------------------------Response Data: ${data['data']}---------------------------",
        );
      } else {
        Get.snackbar("Validation Error", data['message'] ?? "Check your data");
        print("Full Error Response: ${response.body}");
      }
    } catch (e) {
      print(" Error: $e");
      Get.snackbar("خطأ", "حدث خطأ غير متوقع");
    } finally {
      isLoading.value = false;
    }
  }
}
