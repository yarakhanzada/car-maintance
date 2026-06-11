import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/client controller/edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final EditProfileController controller = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                      _buildModernHeader(context, width),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              _buildEnhancedProfileImage(),
                              const SizedBox(height: 40),
                              _buildSectionTitle("المعلومات الشخصية"),
                              const SizedBox(height: 15),
                              _buildModernTextField(
                                "الاسم الكامل",
                                controller.nameController,
                                Icons.person_outline_rounded,
                                readOnly: false,
                              ),
                              _buildModernTextField(
                                "البريد الإلكتروني",
                                controller.emailController,
                                Icons.alternate_email_rounded,
                                readOnly: true,
                              ),
                              _buildModernTextField(
                                "رقم الهاتف",
                                controller.phoneController,
                                Icons.phone_android_rounded,
                                readOnly: false,
                              ),
                              const SizedBox(height: 40),
                              _buildSaveButton(width),
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
      ),
    );
  }

  Widget _buildEnhancedProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE55757).withOpacity(0.2),
              width: 2,
            ),
          ),
          child: const CircleAvatar(
            radius: 65,
            backgroundColor: Color(0xFFD1D1D1),
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(double width) {
    return Obx(() {
      return Container(
        width: width,
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFE55757), Color(0xFFEF8E8E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE55757).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: controller.isLoading.value ? null : controller.updateProfile,
            child: Center(
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "تأكيد التغييرات",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildModernHeader(BuildContext context, double width) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(width * 0.06, 20, width * 0.06, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const Column(
              children: [
                Text(
                  "إعدادات الملف",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  "حدث معلوماتك",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE55757).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 18,
                color: Color(0xFFE55757),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(thickness: 0.5)),
      ],
    );
  }

  Widget _buildModernTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    required bool readOnly,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE55757), size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
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
          color: const Color(0xFFE55757).withOpacity(0.06),
        ),
      ),
    );
  }
}