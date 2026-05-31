import 'dart:convert';

import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:senior_project/model/tow_history_model.dart';
import 'package:senior_project/services/api_config.dart';

import '../../services/api_helper.dart';

class DriverHistoryController extends GetxController {
  var historyList = <TowRequest>[].obs;
  var addressCache = <int, String>{}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchHistory();
    super.onInit();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/v1/driver/tow-requests/history",
      );

      final dataa = jsonDecode(response.body);

      if (response.statusCode == 200 && dataa["status"] == 1) {
        List<dynamic> data = dataa['data'];

        var list = data.map((e) => TowRequest.fromJson(e)).toList();

        historyList.assignAll(list);

        for (var trip in list) {
          _fetchDetailedAddress(trip);
        }
      }
    } catch (e) {
      print("Error fetching history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchDetailedAddress(TowRequest trip) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        trip.lat,
        trip.lng,
      );

      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        String city = p.locality ?? "Damascus";
        String area = p.subLocality ?? "";

        addressCache[trip.towingRequestId] = area.isNotEmpty
            ? "$city, $area"
            : city;
      }
    } catch (e) {
      addressCache[trip.towingRequestId] = "Location Identified";
    }
  }
}
