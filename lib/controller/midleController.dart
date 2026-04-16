import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:senior_project/services/token_service.dart';

class Midlecontroller extends GetxController {
  Future<void> checkLogin() async {
    final token = await TokenService.getToken();
    final role = await TokenService.getRole();
    print("tttttttttttttttttt");
    print(token);

    if (token != null) {
      if (role == "customer") {
        Get.offAllNamed("/client");
      } else if (role == "driver") {
        Get.offAllNamed("/driver");
      } else if (role == "technician") {
        Get.offAllNamed("/tech");
      }
    } else {
      Get.offAllNamed("/ww");
    }
  }
}