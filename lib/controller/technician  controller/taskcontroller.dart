import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_project/controller/technician  controller/complete_maintenance_controller.dart';
import 'package:senior_project/controller/technician  controller/upload_maintenance_images_controller.dart';
import 'package:senior_project/view/Technician/TechnicianBottombar.dart';

class TaskController extends GetxController {
  var taskDetails = Rxn<Map<String, dynamic>>();

  bool get hasActiveTask => taskDetails.value != null;
  var taskId = "".obs;
  var beforeImages = <File>[].obs;
  var afterImages = <File>[].obs;

  var beforeXFiles = <XFile>[].obs;
  var afterXFiles = <XFile>[].obs;

  final imageCtrl = Get.put(MaintenanceImagesController());

  void setTask(Map<String, dynamic> task) {
    taskDetails.value = task;
    beforeImages.clear();
    afterImages.clear();
    beforeXFiles.clear();
    afterXFiles.clear();
  }

  void clearTask() {
    taskDetails.value = null;
  }Future<void> pickImage(ImageSource source, String type) async {
  final XFile? selected = await ImagePicker().pickImage(
    source: source,
    imageQuality: 70,
    maxWidth: 1920,
    maxHeight: 1920,
  );

  if (selected != null) {
    if (type == "Before") {
      beforeImages.add(File(selected.path));
      beforeXFiles.add(selected);
    } else {
      afterImages.add(File(selected.path));
      afterXFiles.add(selected);
    }
  }
}

  Future<void> uploadImages(String type) async {
    List<XFile> files = (type == "Before") ? beforeXFiles : afterXFiles;
    String? id = taskDetails.value?['id']?.toString();

    if (files.isNotEmpty && id != null) {
      await imageCtrl.uploadMaintenanceImages(
        taskId: id,
        selectedImages: files,
        imageType: type.toLowerCase(),
      );
    }
  }Future<void> finishTask() async {
  final String? id = taskDetails.value?['id']?.toString();

  if (id == null) return;

  if (beforeXFiles.isEmpty || afterXFiles.isEmpty) {
    Get.snackbar(
      "تنبيه",
      "يجب إضافة صور قبل إرسال التقرير",
    );
    return;
  }

  final completeCtrl = Get.find<CompleteMaintenanceController>();

  completeCtrl.beforeImages.assignAll(beforeXFiles);
  completeCtrl.afterImages.assignAll(afterXFiles);

  final bool isSuccess =
      await completeCtrl.completeTask(taskId: id);

  if (isSuccess) {
    clearTask();
    Get.offAll(() => TechnicianBottombar());
  }
}
}
