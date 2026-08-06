import 'package:get/get.dart';
import 'package:senior_project/services/token_service.dart';

import 'package:senior_project/services/api_config.dart';

import '../services/api_helper.dart';

class LogoutController extends GetxController {
  var isLoading = false.obs;

  Future<void> logout() async {
    isLoading.value = true;

    String? token = await TokenService.getToken();

       await TokenService.clearSessionData();

    try {
      if (token != null && token.isNotEmpty) {
        await ApiHelper.post("${ApiConfig.baseUrl}/logout", {});
      }
    } catch (e) {
      print("Silent logout error: $e");
    } 
    // finally {
    //   await TokenService.clearSessionData();

    //   isLoading.value = false;

    //   Get.offAll(() => LoginScreen());
    // }

       isLoading.value = false;
  }
}
