import 'dart:convert';
import 'package:get/get.dart';
import 'package:senior_project/controller/towtrucker%20controller/checkactiverequest.dart';
import '../../services/token_service.dart';

class DriverNavigationController extends GetxController {
  var selectedIndex = 0.obs;
  var activeOrderData = Rxn<Map<String, dynamic>>();

  String? currentDriverId;

  @override
  void onInit() {
    super.onInit();
    selectedIndex.value = 0;
    _loadCurrentDriverId();
  }

  Future<void> _loadCurrentDriverId() async {
    currentDriverId = await TokenService.getID();
    await restoreSavedOrder();
  }

  Future<void> restoreSavedOrder() async {
    currentDriverId = await TokenService.getID();

    if (currentDriverId == null || currentDriverId!.isEmpty) {
      activeOrderData.value = null;
      selectedIndex.value = 0;
      return;
    }

    final savedJson = await TokenService.getActiveRequestForUser(
      currentDriverId,
    );
    if (savedJson == null || savedJson.isEmpty) {
      activeOrderData.value = null;
      selectedIndex.value = 0;
      return;
    }

    try {
      final decoded = jsonDecode(savedJson);
      if (decoded is Map<String, dynamic>) {
        final serviceRequestId = decoded['id'];

        if (serviceRequestId != null) {
          final isActive = await checkActiveRequest(
            int.parse(serviceRequestId.toString()),
          );

          if (!isActive) {
            await clearActiveOrder();
            return;
          }
        }

        activeOrderData.value = decoded;
        selectedIndex.value = 1;
      } else if (decoded is Map) {
        activeOrderData.value = Map<String, dynamic>.from(decoded);
        selectedIndex.value = 1;
      } else {
        activeOrderData.value = null;
        selectedIndex.value = 0;
      }
    } catch (_) {
      activeOrderData.value = null;
      selectedIndex.value = 0;
    }
  }

  Future<void> saveActiveOrder(Map<String, dynamic> orderData) async {
    final driverId = currentDriverId ?? await TokenService.getID();
    if (driverId == null || driverId.isEmpty) return;

    await TokenService.saveActiveRequest(
      jsonEncode(orderData),
      userId: driverId,
    );
    activeOrderData.value = orderData;
    selectedIndex.value = 1;
  }

  Future<void> clearActiveOrder() async {
    final driverId = currentDriverId ?? await TokenService.getID();
    if (driverId == null || driverId.isEmpty) return;

    await TokenService.clearActiveRequestForUser(driverId);
    activeOrderData.value = null;
    selectedIndex.value = 0;
  }

  void changePage(int index, {Map<String, dynamic>? orderData}) {
    if (orderData != null) {
      activeOrderData.value = orderData;
    }
    selectedIndex.value = index;
    update();
  }
}
