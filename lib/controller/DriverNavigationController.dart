import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverNavigationController extends GetxController {
  var selectedIndex = 0.obs;
  var isOnline = false.obs;

  void toggleStatus([bool? val]) {
    isOnline.value = val ?? !isOnline.value;
    Get.snackbar(
      "Status Updated",
      isOnline.value ? "You are now ONLINE" : "You are now OFFLINE",
      snackPosition: SnackPosition.TOP,
      backgroundColor: isOnline.value
          ? Colors.green.withOpacity(0.7)
          : Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
  }
}
