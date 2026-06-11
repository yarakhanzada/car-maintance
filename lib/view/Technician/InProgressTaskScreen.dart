import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_project/controller/technician%20%20controller/TaskController.dart';

final TaskController controller = Get.find<TaskController>();

class InProgressTaskScreen extends StatelessWidget {
  const InProgressTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.put(TaskController());
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          _buildBackgroundDecor(screenWidth),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  _buildHeader(screenWidth),
                  SizedBox(height: screenHeight * 0.03),
                  GestureDetector(
                    onTap: () => _showReportSheet(context, screenWidth),
                    child: _buildCurrentJobCard(controller, screenWidth),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildSectionLabel("الخطوة 1: التوثيق", screenWidth),
                  SizedBox(height: screenHeight * 0.015),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildUploadBox(
                            "قبل الإصلاح",
                            controller.beforeImage.value,
                            screenWidth,
                            () => _showImageSourceDialog(
                              context,
                              "Before",
                              controller,
                              screenWidth,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Obx(
                          () => _buildUploadBox(
                            "بعد الإصلاح",
                            controller.afterImage.value,
                            screenWidth,
                            () => _showImageSourceDialog(
                              context,
                              "After",
                              controller,
                              screenWidth,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  _buildSectionLabel("الخطوة 2: حالة المهمة", screenWidth),
                  SizedBox(height: screenHeight * 0.015),
                  _buildStatusSwitcher(controller, screenWidth),
                  SizedBox(height: screenHeight * 0.05),
                  _buildFinishButton(controller, screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportSheet(BuildContext context, double screenWidth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.075),
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
              Text(
                "التقرير الفني",
                style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              _buildReportItem(
                "المشكلة التي تم تحديدها",
                "تلف في شمعات الإشعال وتآكل ملف الإشعال.",
                screenWidth,
              ),
              _buildReportItem(
                "قطع الغيار المطلوبة",
                "عدد 4 شمعات إشعال، ملف إشعال عدد 1 (أصلي)",
                screenWidth,
              ),
              _buildReportItem("الوقت المقدر", "ساعتين", screenWidth),
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
                child: Text(
                  "إغلاق التقرير",
                  style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
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
    double screenWidth,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFE55757)),
              title: const Text("التقاط صورة بالكاميرا"),
              onTap: () {
                controller.pickImage(ImageSource.camera, type);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFE55757)),
              title: const Text("اختيار من المعرض"),
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

  Widget _buildUploadBox(String label, File? imageFile, double screenWidth, VoidCallback onTap) {
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
                  Icon(
                    Icons.add_a_photo_rounded,
                    color: const Color(0xFFE55757),
                    size: screenWidth * 0.08,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.032,
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

  Widget _buildStatusSwitcher(TaskController controller, double screenWidth) {
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
                "قيد العمل",
                controller.status.value == "Working",
                () => controller.status.value = "Working",
              ),
            ),
            Expanded(
              child: _buildSwitchTab(
                "مكتملة",
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

  Widget _buildHeader(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "إدارة المهمة",
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFE55757),
            letterSpacing: 1.5,
          ),
        ),
        Text(
          "قيد التنفيذ",
          style: TextStyle(
            fontSize: screenWidth * 0.08,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentJobCard(TaskController controller, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: screenWidth * 0.06,
            backgroundColor: const Color(0xFFF1F2F6),
            child: const Icon(Icons.car_repair_rounded, color: Colors.black87),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "أودي R8 - حمراء",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: screenWidth * 0.045),
                ),
                Text(
                  "العميل: يارا محمد",
                  style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.032),
                ),
              ],
            ),
          ),
          Obx(() => _buildStatusBadge(controller.status.value, screenWidth)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, double screenWidth) {
    bool isDone = status == "Completed";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isDone ? Colors.blue : Colors.green).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isDone ? "مكتملة" : "قيد العمل",
        style: TextStyle(
          color: isDone ? Colors.blue : Colors.green,
          fontSize: screenWidth * 0.028,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFinishButton(TaskController controller, double screenWidth, double screenHeight) {
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
        onPressed: () async {
          if (controller.beforeImage.value != null) {
            await controller.uploadImages("Before");
          }
          if (controller.afterImage.value != null) {
            await controller.uploadImages("After");
          }
          await controller.finishTask();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE55757),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(
          "إرسال تحديثات المهمة",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: screenWidth * 0.042,
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(TaskController controller, double screenWidth) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: screenWidth * 0.12,
                color: const Color(0xFFE55757),
              ),
              const SizedBox(height: 15),
              Text(
                "التأكيد النهائي",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: screenWidth * 0.055),
              ),
            ],
          ),
          content: Text(
            "هل أنت متأكد من رغبتك في حفظ هذه الصور وتحديث حالة المهمة في النظام؟",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035, height: 1.5),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "مراجعة",
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
                "تأكيد",
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
      "تم بنجاح!",
      "تم إرسال تحديثات المهمة إلى النظام بنجاح.",
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

  Widget _buildSectionLabel(String label, double screenWidth) => Text(
        label,
        style: TextStyle(
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.w800,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      );

  Widget _buildBackgroundDecor(double screenWidth) => Positioned(
        top: -50,
        right: -50,
        child: CircleAvatar(
          radius: screenWidth * 0.3,
          backgroundColor: const Color(0xFFE55757).withOpacity(0.03),
        ),
      );

  Widget _buildReportItem(String title, String value, double screenWidth) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.03,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.038),
            ),
          ],
        ),
      );
}