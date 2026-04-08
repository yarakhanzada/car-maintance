import 'package:get/get.dart';

class LoginController extends GetxController {
  var isPasswordHidden = true.obs;

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  // void handleLogin(String roleTitle) {
  //   if (roleTitle == "Vehicle Owner") {
  //     Get.offAll(() => ClientBottombar());
  //   } else if (roleTitle == "Towing Driver") {
  //     Get.offAll(() => DriverBottombar());
  //   } else if (roleTitle == "Professional Technician") {
  //     Get.offAll(() => TechnicianBottombar());
  //   }
  // }
}
