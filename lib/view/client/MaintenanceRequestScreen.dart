import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/MaintenanceController.dart';
import 'package:senior_project/widgets/CustomButton.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MaintenanceRequestScreen extends StatelessWidget {
  final String categoryName;
  final int categoryId;

  MaintenanceRequestScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  final controller = Get.put(MaintenanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          _buildBackgroundBlurEffect(),
          SafeArea(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGlassToggle(),
                          const SizedBox(height: 30),
                          _buildSectionHeader(
                            "Select Your Vehicle",
                            Icons.directions_car_filled_rounded,
                          ),
                          _buildVehicleDropdown(),
                          const SizedBox(height: 30),
                          _buildSectionHeader(
                            "Service Details",
                            Icons.calendar_today_rounded,
                          ),
                          const SizedBox(height: 15),
                          _buildDateTimeSelectors(context),
                          const SizedBox(height: 30),
                          _buildSectionHeader(
                            "The Issue",
                            Icons.report_problem_rounded,
                          ),
                          _buildModernInput(
                            "Describe the problem...",
                            Icons.notes_rounded,
                            controller.problemController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 30),
                          _buildSectionHeader(
                            "Photos",
                            Icons.camera_enhance_rounded,
                          ),
                          const SizedBox(height: 15),
                          _buildImageUploader(),
                          const SizedBox(height: 40),
                          controller.isLoading.value
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFE55757),
                                  ),
                                )
                              : _buildSubmitButton(),
                          const SizedBox(height: 30),
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
          hint: const Text("Choose vehicle", style: TextStyle(fontSize: 14)),
          value: controller.selectedVehicleId.value,
          items: controller.userVehicles.map((vehicle) {
            return DropdownMenuItem<int>(
              value: vehicle.id,
              child: Text(
                "${vehicle.brand} ${vehicle.model} (${vehicle.chassisNumber})",
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

  Widget _buildDateTimeSelectors(BuildContext context) {
    return Obx(() {
      bool isUrgent = controller.isimmediate.value;
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isUrgent ? null : () => controller.pickDate(context),
              child: _buildInfoCard(
                "Date",
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
                "Time",
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
              // نضيف أيقونة قفل إذا كان غير قابل للتعديل
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
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: textController,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
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
                final XFile? img = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (img != null) controller.images.add(img);
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
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  image: DecorationImage(
                    image: FileImage(File(controller.images[index].path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 15,
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
                    "Processing your request...",
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
              text: "CONFIRM REQUEST",
              onTap: () => controller.submitRequest(categoryId),
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
          _toggleElement(
            "IMMEDIATE",
            controller.isimmediate.value,
            () => controller.updateMaintenanceType(true),
          ),
          _toggleElement(
            "SCHEDULE",
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
      padding: const EdgeInsets.fromLTRB(10, 20, 25, 15),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Service Intake",
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

  Widget _buildBackgroundBlurEffect() {
    return Positioned(
      top: -50,
      left: -50,
      child: Container(
        width: 250,
        height: 250,
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
}
