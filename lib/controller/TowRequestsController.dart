import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:senior_project/model/TowRequestModel.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';


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
    final response = await ApiHelper.get("${ApiConfig.baseUrl}/v1/driver/tow-requests");
          print("lllllllllllllllllllllllllllllllllllllllll");
     print(response.body);
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List rawData = responseData['data']['data']; 
        ordersList.assignAll(rawData.map((e) => TowRequest.fromJson(e)).toList());
      }
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchOrderDetails(int id) async {
  try {
    isLoading(true);
   
    final response = await ApiHelper.get("${ApiConfig.baseUrl}/v1/driver/tow-requests/$id");
   
    if (response.statusCode == 200) {
   
      var responseData = json.decode(response.body);
      
      if (responseData['data'] != null) {
        selectedOrder.value = TowRequest.fromJson(responseData['data']);
   
      }
    }
  } catch (e) {
    print("Error fetching details: $e");
    Get.snackbar("Error", "Could not load details: $e");
  } finally {
    isLoading(false);
  }
}

  Future<void> acceptOrder(int id) async {
    try {
      final response = await ApiHelper.post("${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/accept",{});
        print("lllllllllllllllllllllllllllllllllllllllll");
     print(response.body);
      if (response.statusCode == 200) {
        Get.snackbar("Success", "Order accepted successfully", snackPosition: SnackPosition.BOTTOM);
        fetchOrders(); 
      }
    } catch (e) {
      print("Error accepting order: $e");
    }
  }

  Future<void> rejectOrder(int id) async {
    try {
      final response = await ApiHelper.post("${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/reject",{});
       print("lllllllllllllllllllllllllllllllllllllllll");
     print(response.body);
      if (response.statusCode == 200) {
        Get.snackbar("Ignored", "Request has been skipped", snackPosition: SnackPosition.BOTTOM);
        fetchOrders(); 
      }
    } catch (e) {
      print("Error rejecting order: $e");
    }
  }
}