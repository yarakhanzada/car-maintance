import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senior_project/controller/TowingController.dart';

class TowingFormScreen extends StatelessWidget {
  const TowingFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TowingController());
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildStyleHeader(width),

              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06,
                  vertical: 10,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildTopStatusCard(),
                    const SizedBox(height: 25),

                    _buildSectionHeader(
                      Icons.directions_car_filled_rounded,
                      "Select Your Vehicle",
                    ),
                    _buildModernDropdown(controller),
                    const SizedBox(height: 25),

                    _buildSectionHeader(
                      Icons.report_problem_rounded,
                      "Problem Description",
                    ),
                    _buildModernTextField(controller),
                    const SizedBox(height: 25),

                    _buildSectionHeader(
                      Icons.camera_enhance_rounded,
                      "Visual Evidence",
                    ),
                    _buildModernImagePicker(controller),
                    const SizedBox(height: 40),

                    _buildSubmitButton(controller),

                    const SizedBox(height: 50),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildStyleHeader(double width) {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(width * 0.06, 20, width * 0.06, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Emergency Tow",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Get professional roadside assistance now",
                style: TextStyle(color: Colors.grey[500], fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE55757).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE55757),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "GPS Location",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  "Required for towing arrival",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async => await Geolocator.openLocationSettings(),
            child: const Text(
              "Enable",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE55757),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE55757)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown(TowingController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
          ],
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            icon: const Icon(
              Icons.expand_more_rounded,
              color: Color(0xFFE55757),
            ),
            hint: const Text("Select vehicle from garage"),
            value: controller.selectedVehicleId.value,
            items: controller.userVehicles.map((v) {
              return DropdownMenuItem<int>(
                value: v.id,
                child: Text(
                  "${v.brand} ${v.model}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
            onChanged: (val) => controller.selectedVehicleId.value = val,
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField(TowingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: TextField(
        controller: controller.problemController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Briefly describe the issue...",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildModernImagePicker(TowingController controller) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final List<XFile> picked = await picker.pickMultiImage();
            if (picked.isNotEmpty) controller.images.addAll(picked);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_a_photo_rounded,
                  color: Colors.grey[400],
                  size: 28,
                ),
                const SizedBox(height: 5),
                Text(
                  "Upload snapshots",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => controller.images.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.images.length,
                      itemBuilder: (context, index) =>
                          _buildImageThumb(controller, index),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildImageThumb(TowingController controller, int index) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: FileImage(File(controller.images[index].path)),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () => controller.images.removeAt(index),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 14, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(TowingController controller) {
    return Obx(
      () => controller.isLoading.value
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE55757),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: const Color(0xFFE55757).withOpacity(0.3),
              ),
              onPressed: () => controller.sendTowingRequest(),
              child: const Text(
                "CONFIRM REQUEST",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
    );
  }
}
