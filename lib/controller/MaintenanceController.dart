import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/controller/VehicleController.dart';
import 'package:senior_project/controller/auth_controller.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/token_service.dart';
import 'package:senior_project/services/api_helper.dart';

class MaintenanceController extends GetxController {
  var isLoading = false.obs;
  var isimmediate = true.obs;

  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;
  var selectedVehicleId = RxnInt();
  final problemController = TextEditingController();
  final RxList<XFile> images = <XFile>[].obs;

  final VehicleController _vehicleCtrl = Get.find<VehicleController>();
  List get userVehicles => _vehicleCtrl.vehicleList;

  @override
  void onInit() {
    super.onInit();
    _setImmediateDefaults();
  }

  void updateMaintenanceType(bool immediate) {
    if (isimmediate.value == immediate) return;

    isimmediate.value = immediate;

    problemController.clear();
    images.clear();
    _setImmediateDefaults();
  }

  void _setImmediateDefaults() {
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
  }

  void _showServerSnackBar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey[900]!.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
    );
  }

  Future<void> submitRequest(int departmentId) async {
    if (selectedVehicleId.value == null) {
      _showServerSnackBar("Warning", "Please select a vehicle");
      return;
    }

    isLoading.value = true;

    try {
      if (isimmediate.value) {
        selectedDate.value = DateTime.now();
        selectedTime.value = TimeOfDay.now();
      }

      String formattedTime =
          "${selectedTime.value.hour.toString().padLeft(2, '0')}:${selectedTime.value.minute.toString().padLeft(2, '0')}";

      Map<String, String> fields = {
        'vehicles_id': selectedVehicleId.value.toString(),
        'maintenance_type': isimmediate.value ? 'immediate' : 'scheduled',
        'scheduled_date': selectedDate.value.toString().split(' ')[0],
        'scheduled_time': formattedTime,
        'department_id': departmentId.toString(),
      };

      if (problemController.text.isNotEmpty) {
        fields['problem_type'] = problemController.text;
      }

      final url = "${ApiConfig.baseUrl}/requests/maintenance";
      var response = await _sendMultipartRequest(url, fields, images);

      print("------- API DEBUG START -------");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("------- API DEBUG END ---------");

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 1) {
        Get.back();
        _showServerSnackBar("Success", jsonData['message']);
      } else {
        String errorMsg = jsonData['message'] ?? "Request failed";
        if (jsonData['data'] != null && jsonData['data'] is Map) {
          Map<String, dynamic> errors = jsonData['data'];
          if (errors.isNotEmpty) {
            errorMsg = errors.values.first[0].toString();
          }
        }
        _showServerSnackBar("Failed", errorMsg);
      }
    } catch (e) {
      print("Catch Error: $e");
      _showServerSnackBar(
        "Error",
        "An unexpected error occurred: ${e.toString().split(':').last}",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: "Select a time between 8:00 AM and 1:00 PM",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE55757),
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (picked.hour < 8 || picked.hour >= 13) {
        _showServerSnackBar(
          "Warning",
          "Please select a time between 8:00 AM and 1:00 PM",
        );
      } else {
        selectedTime.value = picked;
      }
    }
  }

  Future<http.Response> _sendMultipartRequest(
    String url,
    Map<String, String> fields,
    List<XFile> files, {
    bool isRetry = false,
  }) async {
    var request = http.MultipartRequest("POST", Uri.parse(url));

    String? token = await TokenService.getToken();
    request.headers.addAll({
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    request.fields.addAll(fields);

    for (var file in files) {
      request.files.add(
        await http.MultipartFile.fromPath('images[]', file.path),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 401 && !isRetry) {
      final authController = Get.find<AuthController>();
      bool refreshed = await authController.refreshToken();

      if (refreshed) {
        return await _sendMultipartRequest(url, fields, files, isRetry: true);
      }
    }

    return response;
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _firstValidDate(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE55757),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
      selectableDayPredicate: (DateTime day) =>
          day.weekday != DateTime.friday && day.weekday != DateTime.saturday,
    );
    if (picked != null) selectedDate.value = picked;
  }

  DateTime _firstValidDate() {
    DateTime date = DateTime.now();
    while (date.weekday == DateTime.friday ||
        date.weekday == DateTime.saturday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}
