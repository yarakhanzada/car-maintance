import 'dart:convert';
import 'package:get/get.dart';
import 'package:senior_project/model/ServiceHistoryModel.dart';
import '../services/api_config.dart';
import '../services/api_helper.dart';

class HistoryController extends GetxController {
  var isLoading = true.obs;
  var requestsList = <ServiceData>[].obs;

  @override
  void onInit() {
    fetchHistory();
    super.onInit();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading(true);
      final response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/customer/requests/history",
      );

      var jsonData = jsonDecode(response.body);
      ServiceHistoryModel model = ServiceHistoryModel.fromJson(jsonData);

      if (response.statusCode == 200) {
        print("Fetched Data: $jsonData");
        if (model.data != null) {
          requestsList.assignAll(model.data!);
        }
        
      }
    } catch (e) {
      print("Error fetching history: $e");
      Get.snackbar("Error", "Connection error: $e");
    } finally {
      isLoading(false);
    }
  }
}
