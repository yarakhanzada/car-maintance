import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DriverNavigationController extends GetxController {
  var selectedIndex = 0.obs;
  final box = GetStorage();
  var activeOrderData = Rxn<Map<String, dynamic>>();
  @override
  void onInit() {
    super.onInit();
    selectedIndex.value = 0;
    //box.erase();

    restoreSavedOrder();
  }

  void restoreSavedOrder() {
    final saved = box.read("active_order");
    print("📍 RAW CACHED ORDER = $saved");

    if (saved != null) {
      activeOrderData.value = Map<String, dynamic>.from(saved);

      print("📍 CACHED LOCATION = ${saved['towing_request']?['location']}");

      selectedIndex.value = 1;
    }
  }

  void changePage(int index, {Map<String, dynamic>? orderData}) {
    if (orderData != null) {
      activeOrderData.value = orderData;
    }
    selectedIndex.value = index;
    update();
  }
}
