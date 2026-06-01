import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_project/services/api_config.dart';
import '../../services/api_helper.dart';

class MaintenanceImagesController extends GetxController {
  var isLoading = false.obs;

  Future<void> uploadMaintenanceImages({
    required String taskId,
    required List<XFile> selectedImages,
    required String imageType,
  }) async {
    if (selectedImages.isEmpty) {
      Get.snackbar("تنبيه", "الرجاء اختيار صورة واحدة على الأقل لرفعها");
      return;
    }

    try {
      isLoading(true);

      String url =
          "${ApiConfig.baseUrl}/v1/technician/maintenance-tasks/$taskId/images";

      Map<String, dynamic> body = {"image_type": imageType};

      final response = await ApiHelper.postWithImages(
        url,
        body,
        selectedImages,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 1) {
          Get.snackbar(
            "نجاح",
            responseData['message'] ?? "تم رفع الصور بنجاح.",
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            "تنبيه",
            responseData['message'] ?? "فشل في رفع الصور",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          "خطأ",
          "فشل الاتصال بالسيرفر. رمز الحالة: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ أثناء معالجة رفع الصور: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
}
