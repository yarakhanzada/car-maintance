import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class TaskController extends GetxController {
  var status = "Working".obs; 
  var beforeImage = Rxn<File>();
  var afterImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source, String type) async {
    final XFile? selected = await _picker.pickImage(source: source);
    if (selected != null) {
      if (type == "Before") {
        beforeImage.value = File(selected.path);
      } else {
        afterImage.value = File(selected.path);
      }
    }
  }
}

class InProgressTaskScreen extends StatelessWidget {
  const InProgressTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.put(TaskController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          _buildBackgroundDecor(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () => _showReportSheet(context),
                    child: _buildCurrentJobCard(controller),
                  ),

                  const SizedBox(height: 30),
                  _buildSectionLabel("STEP 1: DOCUMENTATION"),
                  const SizedBox(height: 15),

         
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildUploadBox(
                            "Before Repair",
                            controller.beforeImage.value,
                            () => _showImageSourceDialog(
                              context,
                              "Before",
                              controller,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Obx(
                          () => _buildUploadBox(
                            "After Repair",
                            controller.afterImage.value,
                            () => _showImageSourceDialog(
                              context,
                              "After",
                              controller,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  _buildSectionLabel("STEP 2: MISSION STATUS"),
                  const SizedBox(height: 15),

              
                  _buildStatusSwitcher(controller),

                  const SizedBox(height: 40),
                  _buildFinishButton(controller),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 
  void _showReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Technical Report",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              _buildReportItem(
                "Issue Identified",
                "Faulty spark plugs and ignition coil wear.",
              ),
              _buildReportItem(
                "Parts Required",
                "4x Spark Plugs, 1x Ignition Coil (OEM)",
              ),
              _buildReportItem("Estimated Time", "2 Hours"),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Close Report",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(
    BuildContext context,
    String type,
    TaskController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFE55757)),
              title: const Text("Take a Photo"),
              onTap: () {
                controller.pickImage(ImageSource.camera, type);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFFE55757),
              ),
              title: const Text("Choose from Gallery"),
              onTap: () {
                controller.pickImage(ImageSource.gallery, type);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildUploadBox(String label, File? imageFile, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFFE55757).withOpacity(0.1),
            width: 2,
          ),
          image: imageFile != null
              ? DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover)
              : null,
        ),
        child: imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_rounded,
                    color: Color(0xFFE55757),
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 40,
                ),
              ),
      ),
    );
  }

 
  Widget _buildStatusSwitcher(TaskController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSwitchTab(
                "Working",
                controller.status.value == "Working",
                () => controller.status.value = "Working",
              ),
            ),
            Expanded(
              child: _buildSwitchTab(
                "Completed",
                controller.status.value == "Completed",
                () => controller.status.value = "Completed",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTab(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? const Color(0xFFE55757) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "MISSION CONTROL",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFFE55757),
            letterSpacing: 2,
          ),
        ),
        Text(
          "In Progress",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentJobCard(TaskController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFF1F2F6),
            child: Icon(Icons.car_repair_rounded, color: Colors.black87),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Audi R8 - Red",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              Text(
                "Customer: Yara Mohammad",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Obx(() => _buildStatusBadge(controller.status.value)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isDone = status == "Completed";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isDone ? Colors.blue : Colors.green).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isDone ? Colors.blue : Colors.green,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- زر الإرسال النهائي (المطلب 3) ---
  Widget _buildFinishButton(TaskController controller) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE55757).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showConfirmationDialog(controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE55757),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: const Text(
          "SUBMIT MISSION UPDATES",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  
  void _showConfirmationDialog(TaskController controller) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: const Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 50,
                color: Color(0xFFE55757),
              ),
              SizedBox(height: 15),
              Text(
                "Final Submission",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to save these photos and update the task status to the system?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "Review",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _showSuccessFlash();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  void _showSuccessFlash() {
    Get.snackbar(
      "Success!",
      "Mission updates have been sent to the system.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 30,
      ),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(15),
      borderRadius: 20,
    );
  }

  Widget _buildSectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: Colors.grey,
      letterSpacing: 1.5,
    ),
  );
  Widget _buildBackgroundDecor() => Positioned(
    top: -50,
    right: -50,
    child: CircleAvatar(
      radius: 120,
      backgroundColor: const Color(0xFFE55757).withOpacity(0.03),
    ),
  );
  Widget _buildReportItem(String t, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          v,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    ),
  );
}
