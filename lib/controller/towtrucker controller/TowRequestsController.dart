import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/controller/towtrucker%20controller/DriverNavigationController.dart';
import 'dart:convert';

import 'package:senior_project/model/TowRequestModel.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';
import 'package:senior_project/view/Tow%20Trucker/DriverMapScreen.dart';

class DriverOrdersController extends GetxController {
  var isLoading = true.obs;
  var ordersList = <TowRequest>[].obs;
  var selectedOrder = Rxn<TowRequest>();

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading(true);
      final response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/v1/driver/tow-requests",
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List rawData = responseData['data'];
        ordersList.assignAll(
          rawData.map((e) => TowRequest.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      debugPrint("خطأ في جلب الطلبات: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchOrderDetails(int id) async {
    try {
      isLoading(true);

      final response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id",
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          selectedOrder.value = TowRequest.fromJson(responseData['data']);
        }
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "تعذر تحميل التفاصيل: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> acceptOrder(int id) async {
    try {
      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/accept",
        {},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final box = GetStorage();
        box.remove("active_order");
        box.write("active_order", responseData["data"]);
        print("Saved Order = ${box.read("active_order")}");
        Get.find<DriverNavigationController>().activeOrderData.value =
            responseData["data"];
        Get.snackbar(
          "نجاح",
          "تم قبول الطلب بنجاح",
          snackPosition: SnackPosition.BOTTOM,
        );
        final navRepo = Get.find<DriverNavigationController>();

        navRepo.changePage(1, orderData: responseData['data']);
        fetchOrders();
      }
    } catch (e) {
      debugPrint("خطأ في قبول الطلب: $e");
    }
  }

  Future<void> rejectOrder(int id) async {
    try {
      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/reject",
        {},
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "تم التجاهل",
          "تم تخطي الطلب",
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchOrders();
      }
    } catch (e) {
      debugPrint("خطأ في رفض الطلب: $e");
    }
  }
}
