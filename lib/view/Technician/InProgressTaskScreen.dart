import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senior_project/controller/technician%20%20controller/complete_maintenance_controller.dart';
import 'package:senior_project/controller/technician%20%20controller/taskcontroller.dart';

class InProgressTaskScreen extends StatelessWidget {
  const InProgressTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final TaskController controller = Get.find<TaskController>();
    final CompleteMaintenanceController completeCtrl =
        Get.find<CompleteMaintenanceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          _buildBackgroundDecor(screenWidth),
          SafeArea(
            child: Obx(
              () => !controller.hasActiveTask
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(screenWidth),
                          const SizedBox(height: 25),

                          _buildSectionLabel("ملاحظات المهندس"),
                          _buildCurrentJobCard(controller),
                          const SizedBox(height: 25),

                          // تصميم احترافي للصور
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildImageSection(
                                        "قبل الإصلاح",
                                        Icons.camera_alt_outlined,
                                        controller.beforeImages,
                                        () => _showImageSourceDialog(
                                          context,
                                          "Before",
                                          controller,
                                        ),
                                        (index) => controller.beforeImages
                                            .removeAt(index),
                                      ),
                                    ),
                                    VerticalDivider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                    Expanded(
                                      child: _buildImageSection(
                                        "بعد الإصلاح",
                                        Icons.check_circle_outline,
                                        controller.afterImages,
                                        () => _showImageSourceDialog(
                                          context,
                                          "After",
                                          controller,
                                        ),
                                        (index) => controller.afterImages
                                            .removeAt(index),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),
                          _buildSectionLabel("الخطوة 2: ملاحظات إضافية"),
                          const SizedBox(height: 10),
                          _buildNotesTextField(completeCtrl),
                          const SizedBox(height: 30),
                          _buildFinishButton(controller),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Color(0xFF555555),
      ),
    ),
  );

  Widget _buildImageSection(
    String title,
    IconData icon,
    RxList<File> images,
    VoidCallback onAdd,
    Function(int) onRemove,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFE55757)),
            const SizedBox(width: 5),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...images.asMap().entries.map(
              (entry) => Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(entry.value),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => onRemove(entry.key),
                      child: const Icon(Icons.cancel, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.add_a_photo, color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentJobCard(TaskController controller) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Obx(
      () => Text(
        controller
                .taskDetails
                .value?['maintenance_request']?['engineer_notes'] ??
            "لا توجد تفاصيل",
      ),
    ),
  );

  Widget _buildNotesTextField(CompleteMaintenanceController completeCtrl) =>
      TextField(
        controller: completeCtrl.notesController,
        maxLines: 3,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "أضف ملاحظاتك هنا...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _buildFinishButton(TaskController controller) {
    final completeCtrl = Get.find<CompleteMaintenanceController>();

    return Obx(
      () => ElevatedButton(
        onPressed: completeCtrl.isLoading.value
            ? null
            : () => controller.finishTask(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE55757),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: completeCtrl.isLoading.value
            ? LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 30,
              )
            : const Text(
                "إرسال المهمة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(Get.width),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 50,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "لا توجد مهمة قيد التنفيذ حالياً",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text(
        "إدارة المهمة",
        style: TextStyle(color: Color(0xFFE55757), fontWeight: FontWeight.bold),
      ),
      Text(
        "قيد التنفيذ",
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
      ),
    ],
  );

  Widget _buildBackgroundDecor(double screenWidth) => Positioned(
    top: -50,
    right: -50,
    child: CircleAvatar(
      radius: screenWidth * 0.3,
      backgroundColor: const Color(0xFFE55757).withOpacity(0.05),
    ),
  );

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
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("كاميرا"),
              onTap: () {
                controller.pickImage(ImageSource.camera, type);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("معرض الصور"),
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
}
