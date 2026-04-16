

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          _buildTopGradient(),
          SafeArea(
            child: GetBuilder<EditProfileController>(
              builder: (_) {
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildHeader(context, width),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            _buildImage(),
                            const SizedBox(height: 40),
                            _buildSectionTitle("Personal Information"),
                            const SizedBox(height: 15),
                            _buildField("Full Name", controller.nameController, Icons.person, readOnly: false),
                           _buildField("Email", controller.emailController, Icons.email, readOnly: true),
                            _buildField("Phone", controller.phoneController, Icons.phone, readOnly: false),
                            const SizedBox(height: 40),
                            _buildButton(controller, width),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return const CircleAvatar(
      radius: 65,
      child: Icon(Icons.person, size: 60),
    );
  }

  Widget _buildButton(EditProfileController controller, double width) {
    return Obx(() {
      return SizedBox(
        width: width,
        height: 60,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.updateProfile,
          child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Save"),
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context, double width) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(width * 0.06),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
            ),
            const Spacer(),
            const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
  String label,
  TextEditingController controller,
  IconData icon, {
  required bool readOnly,
}) {
  return TextField(
    controller: controller,
    readOnly: readOnly,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _buildTopGradient() {
    return Positioned(
      top: -50,
      left: -50,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withOpacity(0.06),
        ),
      ),
    );
  }
}