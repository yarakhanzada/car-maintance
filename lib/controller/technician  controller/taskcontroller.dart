import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_project/controller/technician%20%20controller/complete_maintenance_controller.dart';
import 'package:senior_project/controller/technician%20%20controller/upload_maintenance_images_controller.dart';

class TaskController extends GetxController {
  var taskId = "".obs;
  var taskDetails = Rxn<Map<String, dynamic>>();
  var status = "Working".obs;
  var beforeImage = Rxn<File>();
  var afterImage = Rxn<File>();

  var beforeXFile = Rxn<XFile>();
  var afterXFile = Rxn<XFile>();

  final imageCtrl = Get.put(MaintenanceImagesController());
  final completeCtrl = Get.put(CompleteMaintenanceController());

  Future<void> pickImage(ImageSource source, String type) async {
    final XFile? selected = await ImagePicker().pickImage(source: source);
    if (selected != null) {
      if (type == "Before") {
        beforeImage.value = File(selected.path);
        beforeXFile.value = selected;
      } else {
        afterImage.value = File(selected.path);
        afterXFile.value = selected;
      }
    }
  }

  Future<void> uploadImages(String type) async {
    XFile? file = (type == "Before") ? beforeXFile.value : afterXFile.value;
    if (file != null && taskId.isNotEmpty) {
      await imageCtrl.uploadMaintenanceImages(
        taskId: taskId.value,
        selectedImages: [file],
        imageType: type.toLowerCase(),
      );
    }
  }

  Future<void> finishTask() async {
    if (taskId.isNotEmpty) {
      await completeCtrl.completeTask(taskId: taskId.value);
    }
  }
}
