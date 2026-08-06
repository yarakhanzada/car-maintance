import 'dart:convert';
import 'package:get/get.dart';
import 'package:senior_project/model/technician%20model/technician_profile_model.dart';
import '../../services/api_config.dart';
import '../../services/api_helper.dart';

class TechnicianProfileController extends GetxController {
  var isLoading = true.obs;
  var profileData = Rxn<TechnicianData>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);

      final response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/v1/technician/profile",
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 1) {
          final profileModel = TechnicianProfileModel.fromJson(responseData);
          profileData.value = profileModel.data;
        } else {
          Get.snackbar(
            "تنبيه",
            responseData['message'] ?? "فشل في جلب بيانات الملف الشخصي",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          "خطأ",
          "فشل الاتصال بالسيرفر. رمز الحالة: ${response.statusCode ?? 'غير معروف'}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ أثناء معالجة البيانات: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
}
