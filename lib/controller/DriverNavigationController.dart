import 'package:get/get.dart';

class DriverNavigationController extends GetxController {
  var selectedIndex = 0.obs;

  var activeOrderData = Rxn<Map<String, dynamic>>();
  @override
  void onInit() {
    super.onInit();
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
