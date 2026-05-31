import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/controller/auth_controller.dart';
import 'package:senior_project/model/profile_model.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/token_service.dart';

import '../../services/api_helper.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var profile = Rxn<ProfileModel>();

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      isLoading.value = true;
      String? token = await TokenService.getToken();
      final response = await ApiHelper.get("${ApiConfig.baseUrl}/me");
      final data = jsonDecode(response.body);
      print("??????????????????????");
      print(data);
      if (response.statusCode == 200) {
        if (data['status'] == 1) {
          profile.value = ProfileModel.fromJson(data['data']);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile");
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
