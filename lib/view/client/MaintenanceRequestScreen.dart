import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/client controller/MaintenanceController.dart';
import 'package:senior_project/controller/client%20controller/departmentController.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MaintenanceRequestScreen extends StatelessWidget {
  final String categoryName;
  final int? categoryId;
  final deptController = Get.put(DepartmentController());
  MaintenanceRequestScreen({
    super.key,
    required this.categoryName,
    this.categoryId,
  });

  final controller = Get.put(MaintenanceController());

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initDepartments(categoryId);
    });
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Stack(
          children: [
            _buildBackgroundBlurEffect(screenWidth),
            SafeArea(
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimatedHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
  _buildGlassToggle(),
  const SizedBox(height: 30),

  _buildSectionHeader(
    "اختر مركبتك",
    Icons.directions_car_filled_rounded,
  ),
  _buildVehicleDropdown(),

  const SizedBox(height: 30),

  _buildSectionHeader(
    "تفاصيل الخدمة",
    Icons.calendar_today_rounded,
  ),

  const SizedBox(height: 15),

  _buildDateTimeSelectors(context),

  const SizedBox(height: 30),

  /// If it's general maintenance
  if (categoryId == null || categoryId == 0) ...[
    _buildSectionHeader(
      "المشكلة",
      Icons.report_problem_rounded,
    ),

    const SizedBox(height: 15),

    _buildModernInput(
      "صف المشكلة",
      Icons.notes_rounded,
      controller.problemControllers.putIfAbsent(
        0,
        () => TextEditingController(),
      ),
      minLines: 3,
  maxLines: 5,
    ),

    const SizedBox(height: 30),
  ],

  if (categoryId != null && categoryId != 0) ...[
    _buildSectionHeader(
      "هل ترغب بإضافة أقسام أخرى؟",
      Icons.category_rounded,
    ),

    const SizedBox(height: 15),

    _buildDepartmentSelector(),

    const SizedBox(height: 25),

    _buildDepartmentProblems(),

    const SizedBox(height: 30),
  ],

  _buildSubmitButton(),

  const SizedBox(height: 40),
],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: const Text("اختر المركبة", style: TextStyle(fontSize: 14)),
          value: controller.selectedVehicleId.value,
          items: controller.userVehicles.map((vehicle) {
            return DropdownMenuItem<int>(
              value: vehicle.id,
              child: Text(
                "${vehicle.brand} ${vehicle.model} (${vehicle.plate_number})",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) => controller.selectedVehicleId.value = val,
        ),
      ),
    );
  }

  Widget _buildDepartmentSelector() {
    return Obx(() {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: deptController.departments.map((dept) {
          bool isSelected = controller.selectedDepartmentIds.contains(dept.id);
          bool isPrimary = (dept.id == controller.initialDepartmentId);

          return GestureDetector(
            onTap: isPrimary
                ? null
                : () => controller.toggleDepartment(dept.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (isSelected || isPrimary)
                    ? const Color(0xFFE55757)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: (isSelected || isPrimary)
                      ? const Color(0xFFE55757)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // to take up only the text's size
                children: [
                  Icon(
                    isPrimary
                        ? Icons.lock
                        : (isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined),
                    color: (isSelected || isPrimary)
                        ? Colors.white
                        : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dept.name,
                    style: TextStyle(
                      color: (isSelected || isPrimary)
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildDateTimeSelectors(BuildContext context) {
    return Obx(() {
      bool isUrgent = controller.isimmediate.value;
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isUrgent ? null : () => controller.pickDate(context),
              child: _buildInfoCard(
                "التاريخ",
                controller.selectedDate.value.toString().split(' ')[0],
                Icons.event,
                isEditable: !isUrgent,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: isUrgent ? null : () => controller.pickTime(context),
              child: _buildInfoCard(
                "الوقت",
                controller.selectedTime.value.format(context),
                Icons.access_time_rounded,
                isEditable: !isUrgent,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon, {
    bool isEditable = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isEditable ? Colors.white : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: isEditable
            ? Border.all(color: Colors.transparent)
            : Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isEditable ? const Color(0xFFE55757) : Colors.grey,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const Spacer(),
              if (!isEditable)
                Icon(Icons.lock_outline, size: 12, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isEditable ? Colors.black : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildModernInput(
  String hint,
  IconData icon,
  TextEditingController textController, {
  int minLines = 1,
  int maxLines = 5,
}) {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey[400],
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: TextField(
            controller: textController,
            minLines: minLines,
            maxLines: maxLines,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildImageUploader() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.images.length < 3
            ? controller.images.length + 1
            : controller.images.length,
        itemBuilder: (context, index) {
          if (index == controller.images.length) {
            return GestureDetector(
              onTap: () async {
                if (controller.isPickingImage.value) return;

                controller.isPickingImage.value = true;

                try {
                  final XFile? img = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );

                  if (img != null) {
                    controller.images.add(img);
                  }
                } catch (e) {
                  print(e);
                } finally {
                  controller.isPickingImage.value = false;
                }
              },
              child: Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFE55757).withOpacity(0.2),
                  ),
                ),
                child: const Icon(
                  Icons.add_a_photo_rounded,
                  color: Color(0xFFE55757),
                ),
              ),
            );
          }
          return Stack(
            children: [
              Container(
                width: 85,
                height: 85,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  image: DecorationImage(
                    image: FileImage(File(controller.images[index].path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 5,
                child: GestureDetector(
                  onTap: () => controller.images.removeAt(index),
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, size: 12, color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => controller.isLoading.value
          ? Center(
              child: Column(
                children: [
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: const Color(0xFFE55757),
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "جاري معالجة طلبك...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : CustomButton(
              text: "تأكيد الطلب",
              onTap: () => controller.submitRequest(),
            ),
    );
  }

  Widget _buildGlassToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // _toggleElement(
          //   "فوري",
          //   controller.isimmediate.value,
          //   () => controller.updateMaintenanceType(true),
          // ),
          _toggleElement(
            "جدولة",
            !controller.isimmediate.value,
            () => controller.updateMaintenanceType(false),
          ),
        ],
      ),
    );
  }

  Widget _toggleElement(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE55757) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey[500],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE55757), size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 10, 15),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 22),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "استلام الخدمة",
                style: TextStyle(
                  color: const Color(0xFFE55757).withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                categoryName,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.build_circle_outlined,
            color: Color(0xFFE55757),
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlurEffect(double screenWidth) {
    return Positioned(
      top: -50,
      right: -50,
      child: Container(
        width: screenWidth * 0.6,
        height: screenWidth * 0.6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
  Widget _buildDepartmentProblems() {
  return Obx(() {
    return Column(
      children: controller.selectedDepartmentIds.map((departmentId) {
        final dept = deptController.departments.firstWhere(
          (e) => e.id == departmentId,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                dept.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 15),

             _buildModernInput(
  "صف المشكلة الخاصة بقسم ${dept.name}",
  Icons.notes_rounded,
  controller.problemControllers.putIfAbsent(
    departmentId,
    () => TextEditingController(),
  ),
  minLines: 1,
  maxLines: 5,
),
            ],
          ),
        );
      }).toList(),
    );
  });
}
}
