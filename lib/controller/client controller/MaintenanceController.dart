// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:senior_project/controller/client controller/VehicleController.dart';
// import 'package:senior_project/services/api_config.dart';
// import 'package:senior_project/services/api_helper.dart';

// class MaintenanceController extends GetxController {
//   var isLoading = false.obs;
//   var isimmediate = true.obs;

//   var selectedDate = DateTime.now().obs;
//   var selectedTime = TimeOfDay.now().obs;
//   var selectedVehicleId = RxnInt();
//   final problemController = TextEditingController();
//   final RxList<XFile> images = <XFile>[].obs;

//   final VehicleController _vehicleCtrl = Get.find<VehicleController>();
//   List get userVehicles => _vehicleCtrl.vehicleList;
//   int? initialDepartmentId;
// var selectedDepartmentIds = <int>[].obs;

// void toggleDepartment(int id) {
//     if (selectedDepartmentIds.contains(id)) {
//       selectedDepartmentIds.remove(id);
//     } else {
//       selectedDepartmentIds.add(id);
//     }
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     _setImmediateDefaults();
//   }

//   void updateMaintenanceType(bool immediate) {
//     if (isimmediate.value == immediate) return;
//     isimmediate.value = immediate;
//     problemController.clear();
//     images.clear();
//     _setImmediateDefaults();
//   }

//   void _setImmediateDefaults() {
//     selectedDate.value = DateTime.now();
//     selectedTime.value = TimeOfDay.now();
//   }

//   void _showServerSnackBar(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.grey[900]!.withOpacity(0.9),
//       colorText: Colors.white,
//       margin: const EdgeInsets.all(15),
//       borderRadius: 10,
//     );
//   }

//   Future<void> submitRequest(int? departmentId) async {
//     if (selectedVehicleId.value == null) {
//       _showServerSnackBar("تنبيه", "يرجى اختيار مركبة");
//       return;
//     }
// if (selectedDepartmentIds.isEmpty) {
//       _showServerSnackBar("تنبيه", "يرجى اختيار قسم واحد على الأقل");
//       return;
//     }
//     isLoading.value = true;

//     try {
//       if (isimmediate.value) {
//         selectedDate.value = DateTime.now();
//         selectedTime.value = TimeOfDay.now();
//       }

//       String formattedTime =
//           "${selectedTime.value.hour.toString().padLeft(2, '0')}:${selectedTime.value.minute.toString().padLeft(2, '0')}";

//       Map<String, dynamic> fields = {
//         'vehicles_id': selectedVehicleId.value.toString(),
//         'maintenance_type': isimmediate.value ? 'immediate' : 'scheduled',
//         'scheduled_date': selectedDate.value.toString().split(' ')[0],
//         'scheduled_time': formattedTime,
//       };
//       for (int i = 0; i < selectedDepartmentIds.length; i++) {
//         fields['department_ids[$i]'] = selectedDepartmentIds[i].toString();
//       }

//       // if (departmentId != null && departmentId > 0) {
//       //   fields['department_id'] = departmentId.toString();
//       // }

//       if (problemController.text.isNotEmpty) {
//         fields['problem_type'] = problemController.text;
//       }

//       final url = "${ApiConfig.baseUrl}/requests/maintenance";

//       var response = await ApiHelper.postWithImages(url, fields, images);

//       print("------- API DEBUG START -------");
//       print("Status Code: ${response.statusCode}");
//       print("Response Body: ${response.body}");
//       print("------- API DEBUG END ---------");

//       final jsonData = jsonDecode(response.body);

//       if (response.statusCode == 200 && jsonData['status'] == 1) {
//         Get.back();
//         _showServerSnackBar("Success", jsonData['message']);
//       } else {
//         String errorMsg = jsonData['message'] ?? "Request failed";
//         if (jsonData['data'] != null && jsonData['data'] is Map) {
//           Map<String, dynamic> errors = jsonData['data'];
//           if (errors.isNotEmpty) {
//             errorMsg = errors.values.first[0].toString();
//           }
//         }
//         _showServerSnackBar("Failed", errorMsg);
//       }
//     } catch (e) {
//       print("Catch Error: $e");
//       _showServerSnackBar(
//         "Error",
//         "An unexpected error occurred: ${e.toString().split(':').last}",
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> pickTime(BuildContext context) async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: const TimeOfDay(hour: 8, minute: 0),
//       helpText: "Select a time between 8:00 AM and 1:00 PM",
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFFE55757),
//             onSurface: Color(0xFF1A1A1A),
//           ),
//         ),
//         child: child!,
//       ),
//     );

//     if (picked != null) {
//       if (picked.hour < 8 || picked.hour >= 13) {
//         _showServerSnackBar(
//           "Warning",
//           "Select time between 8:00 AM and 1:00 PM",
//         );
//       } else {
//         selectedTime.value = picked;
//       }
//     }
//   }

//   Future<void> pickDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,

//       initialDate: _firstValidDate(),

//       firstDate: DateTime.now(),

//       lastDate: DateTime(2030, 12, 31),

//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFE55757),

//               onPrimary: Colors.white,

//               onSurface: Color(0xFF1A1A1A),
//             ),
//           ),

//           child: child!,
//         );
//       },

//       selectableDayPredicate: (DateTime day) =>
//           day.weekday != DateTime.friday && day.weekday != DateTime.saturday,
//     );

//     if (picked != null) selectedDate.value = picked;
//   }

//   DateTime _firstValidDate() {
//     DateTime date = DateTime.now();
//     while (date.weekday == DateTime.friday ||
//         date.weekday == DateTime.saturday) {
//       date = date.add(const Duration(days: 1));
//     }
//     return date;
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_project/controller/client controller/VehicleController.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';

class MaintenanceController extends GetxController {
  var isLoading = false.obs;
  var isimmediate = false.obs;
  var isInitialized = false;
  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;
  var selectedVehicleId = RxnInt();
  final Map<int, TextEditingController> problemControllers = {};
  final RxList<XFile> images = <XFile>[].obs;
  RxBool isPickingImage = false.obs;
  final VehicleController _vehicleCtrl = Get.find<VehicleController>();
  List get userVehicles => _vehicleCtrl.vehicleList;

  int? initialDepartmentId;
  var selectedDepartmentIds = <int>[].obs;
  void printFullResponse(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  void initDepartments(int? categoryId) {
    initialDepartmentId = categoryId;

    if (initialDepartmentId != null &&
        !selectedDepartmentIds.contains(initialDepartmentId)) {
      selectedDepartmentIds.add(initialDepartmentId!);
      problemControllers.putIfAbsent(
        initialDepartmentId!,
        () => TextEditingController(),
      );
    }
  }

  void toggleDepartment(int id) {
    if (initialDepartmentId != null && id == initialDepartmentId) return;

    if (selectedDepartmentIds.contains(id)) {
      selectedDepartmentIds.remove(id);

      problemControllers[id]?.dispose();
      problemControllers.remove(id);
    } else {
      selectedDepartmentIds.add(id);

      problemControllers.putIfAbsent(id, () => TextEditingController());
    }
    selectedDepartmentIds.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    _setImmediateDefaults();
  }

  void updateMaintenanceType(bool immediate) {
    if (isimmediate.value == immediate) return;
    isimmediate.value = immediate;
    for (final controller in problemControllers.values) {
      controller.clear();
    }
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

  Future<void> submitRequest() async {
    if (selectedVehicleId.value == null) {
      _showServerSnackBar("تنبيه", "يرجى اختيار مركبة");
      return;
    }

    if ((initialDepartmentId != null) && selectedDepartmentIds.isEmpty) {
      _showServerSnackBar("تنبيه", "يرجى اختيار قسم واحد على الأقل");
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

      Map<String, dynamic> fields = {
        'vehicles_id': selectedVehicleId.value.toString(),
        'maintenance_type': isimmediate.value ? 'immediate' : 'scheduled',
        'scheduled_date': selectedDate.value.toString().split(' ')[0],
        'scheduled_time': formattedTime,
      };

      if (initialDepartmentId != null) {
        if (selectedDepartmentIds.isEmpty) {
          selectedDepartmentIds.add(initialDepartmentId!);
        }

        for (int i = 0; i < selectedDepartmentIds.length; i++) {
          final id = selectedDepartmentIds[i];

          fields['departments[$i][id]'] = id.toString();
          fields['departments[$i][description]'] =
              problemControllers[id]?.text ?? "";
        }
      }

      final url = "${ApiConfig.baseUrl}/requests/maintenance";

      var response = await ApiHelper.postWithImages(url, fields, images);

      print("Selected Department IDs List: ${selectedDepartmentIds.toList()}");
      print("------- API FULL RESPONSE DEBUG START -------");
      print("Status Code: ${response.statusCode}");
      printFullResponse(response.body);
      print("------- API FULL RESPONSE DEBUG END -------");

      final jsonData = jsonDecode(response.body);
      print("Parsed Keys: ${jsonData.keys.toList()}");

    if (response.statusCode == 200 && jsonData['status'] == 1) {
  problemControllers.clear();
  selectedDepartmentIds.clear();
  images.clear();

  isInitialized = false;

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
      helpText: "اختار وقت بين 8:00 صباحاً و 1:00 ظهراً",
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE55757),
            onSurface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      if (picked.hour < 8 || picked.hour >= 13) {
        _showServerSnackBar("تنبيه", "اختار وقت بين 8:00 صباحاً و 1:00 ظهراً");
      } else {
        selectedTime.value = picked;
      }
    }
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _firstValidDate(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12, 31),
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
      selectableDayPredicate: (DateTime day) => day.weekday != DateTime.friday,
    );

    if (picked != null) selectedDate.value = picked;
  }

  DateTime _firstValidDate() {
    DateTime date = DateTime.now();
    while (date.weekday == DateTime.friday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
  @override
void onClose() {
  for (final controller in problemControllers.values) {
    controller.dispose();
  }

  problemControllers.clear();

  super.onClose();
}
}
