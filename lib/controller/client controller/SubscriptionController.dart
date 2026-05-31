import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/model/subscriptionModel.dart';
import 'package:senior_project/services/api_config.dart';
import '../../services/api_helper.dart';

class SubscriptionController extends GetxController {
  var isLoading = true.obs;
  var subscriptions = <SubscriptionModel>[].obs;
  var isSubscribing = false.obs;
  var mySubscriptions = <dynamic>[].obs;

  @override
  void onInit() {
    fetchSubscriptions();
    getMySubscriptions();
    super.onInit();
  }

  Future<void> getMySubscriptions() async {
    try {
      isLoading(true);

      var response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/customer/subscriptions",
      );
      final data = jsonDecode(response.body);
      print("LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL");
      print(data);
      if (response.statusCode == 200) {
        var jsonData = response.body is String
            ? json.decode(response.body)
            : response.body;

        if (jsonData['status'] == 1 || jsonData['status'] == "1") {
          var singleSubscription = jsonData['data'];
          mySubscriptions.assignAll([singleSubscription]);

          print("Subscription loaded successfully as a list");
        } else {
          Get.snackbar(
            "Alert",
            jsonData['message'] ?? "No active subscriptions found",
          );
        }
      } else {
        var errorData = response.body is String
            ? json.decode(response.body)
            : response.body;
        String errorMsg =
            errorData?['message'] ?? "Server Error: ${response.statusCode}";
        Get.snackbar("Error", errorMsg);
      }
    } catch (e) {
      print("Error in getMySubscriptions: $e");
      Get.snackbar("Error", "Something went wrong, please try again");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSubscriptions() async {
    try {
      isLoading(true);

      var response = await ApiHelper.get("${ApiConfig.baseUrl}/subscriptions");

      if (response.statusCode == 200) {
        var jsonData = response.body is String
            ? json.decode(response.body)
            : response.body;

        if (jsonData['status'] == 1 || jsonData['status'] == "1") {
          var list = jsonData['data'] as List;

          subscriptions.assignAll(
            list.map((e) => SubscriptionModel.fromJson(e)).toList(),
          );
        } else {
          Get.snackbar("Alert", jsonData['message'] ?? "Failed to load data");
        }
      } else {
        var errorData = response.body is String
            ? json.decode(response.body)
            : response.body;
        String errorMsg =
            errorData?['message'] ?? "Server Error: ${response.statusCode}";
        Get.snackbar("Error", errorMsg);
      }
    } catch (e) {
      print("Error in fetchSubscriptions: $e");
      Get.snackbar("Error", "Check your internet connection");
    } finally {
      isLoading(false);
    }
  }

  Future<void> subscribeToPackage(int subscriptionId) async {
    try {
      isSubscribing(true);

      var response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/subscriptions/$subscriptionId/join",
        {},
      );

      var jsonData = response.body is String
          ? json.decode(response.body)
          : response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonData['status'] == 1) {
          Get.snackbar(
            "Success",
            jsonData['message'] ?? "Subscribed successfully!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.grey.withOpacity(0.1),
          );
          await Get.find<SubscriptionController>().getMySubscriptions();

          Get.back();
        }
      } else {
        String errorMsg = jsonData['message'] ?? "Subscription failed";
        Get.snackbar("Error", errorMsg);
      }
    } catch (e) {
      Get.snackbar("Error", "Check your internet connection");
    } finally {
      isSubscribing(false);
    }
  }

  void _showSuccessSnackBar(String message) {
    Get.snackbar(
      "Success",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.withOpacity(0.8),
      colorText: Colors.black,
      margin: const EdgeInsets.all(15),
    );
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.withOpacity(0.8),
      colorText: Colors.black,
      margin: const EdgeInsets.all(15),
    );
  }
}
