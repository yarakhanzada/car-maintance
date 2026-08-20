import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_project/controller/technician  controller/complete_maintenance_controller.dart';
import 'package:senior_project/controller/technician  controller/task_details_controller.dart';
import 'package:senior_project/controller/technician  controller/upload_maintenance_images_controller.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';
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

  @override
  void onInit() {
    super.onInit();
    restoreActiveTask();
  }

  // The technician's in-progress task otherwise only lived in memory, so
  // closing and reopening the app (or a fresh Get.put on this controller)
  // lost it even though the task was still in_progress on the server.
  Future<void> restoreActiveTask() async {
    try {
      final response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/v1/technician/maintenance-tasks?status=in_progress",
      );

      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['status'] != 1) return;

      final tasks = decoded['data'] as List?;
      if (tasks == null || tasks.isEmpty) return;

      final task = Map<String, dynamic>.from(tasks.first);
      setTask(task);

      final id = task['id'];
      if (id == null) return;

      final detailsController = Get.isRegistered<TaskDetailsController>()
          ? Get.find<TaskDetailsController>()
          : Get.put(TaskDetailsController());
      await detailsController.fetchTaskDetails(int.parse(id.toString()));
    } catch (e) {
      print(" Error restoring active task: $e");
    }
  }

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
