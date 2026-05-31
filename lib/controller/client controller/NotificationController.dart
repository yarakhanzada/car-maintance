import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/api_helper.dart';
import '../../../services/api_config.dart';

class NotificationController extends GetxController {
  var notifications = <dynamic>[].obs;
  var isLoading = false.obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print("NotificationController: Initializing controller");
    fetchNotifications();
    getUnreadCount();
  }

  // 1. جلب قائمة الإشعارات
  Future<void> fetchNotifications() async {
    try {
      print("NotificationController: Fetching notifications from API...");
      isLoading(true);
      var response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/customer/notifications",
      );

      var jsonData = response.body is String
          ? json.decode(response.body)
          : response.body;
      print("Debug JSON: $jsonData");
      if (response.statusCode == 200 && jsonData['status'] == 1) {
        var list = jsonData['data'] as List;
        notifications.assignAll(list);
        print(
          "NotificationController: Successfully fetched ${list.length} notifications",
        );
      } else {
        print(
          "NotificationController: Failed to fetch notifications. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("NotificationController: Exception in fetchNotifications: $e");
    } finally {
      isLoading(false);
    }
  }

  // 2. جلب عدد الإشعارات غير المقروءة
  Future<void> getUnreadCount() async {
    try {
      print("NotificationController: Requesting unread count...");
      var response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/customer/notifications/unread-count",
      );

      var jsonData = response.body is String
          ? json.decode(response.body)
          : response.body;

      if (response.statusCode == 200 && jsonData['status'] == 1) {
        unreadCount.value = jsonData['data']['unread_count'];
        print(
          "NotificationController: Unread count updated to: ${unreadCount.value}",
        );
      }
    } catch (e) {
      print("NotificationController: Exception in getUnreadCount: $e");
    }
  }

  // 3. تمييز إشعار واحد كمقروء
  Future<void> markAsRead(int id) async {
    try {
      print(
        "NotificationController: Marking notification ID $id as read using POST...",
      );

      var response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/customer/notifications/$id/read",
        {},
      );

      var jsonData = response.body is String
          ? json.decode(response.body)
          : response.body;

      if (response.statusCode == 200 && jsonData['status'] == 1) {
        int index = notifications.indexWhere((n) => n['id'] == id);

        if (index != -1) {
          notifications[index]['is_read'] = true;
          notifications.refresh();

          if (unreadCount.value > 0) {
            unreadCount.value--;
          }

          print(
            "NotificationController: Notification $id updated successfully",
          );
          _showSnackBar("Success", jsonData['message']);
        }
      } else {
        print(
          "NotificationController: Error from server: ${jsonData['message']}",
        );
      }
    } catch (e) {
      print("NotificationController: Exception in markAsRead: $e");
    }
  }

  // 4. تمييز الكل كمقروء
  Future<void> markAllAsRead() async {
    try {
      print("NotificationController: Marking all as read using POST...");

      var response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/customer/notifications/read-all",
        {},
      );

      var jsonData = response.body is String
          ? json.decode(response.body)
          : response.body;

      if (response.statusCode == 200 && jsonData['status'] == 1) {
        for (var n in notifications) {
          n['is_read'] = true;
        }
        notifications.refresh();
        unreadCount.value = 0;

        print("NotificationController: All marked as read successfully");
        _showSnackBar("Success", jsonData['message']);
      }
    } catch (e) {
      print("NotificationController: Exception in markAllAsRead: $e");
    }
  }

  void _showSnackBar(String title, String? message) {
    if (message == null) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 2),
    );
  }
}
