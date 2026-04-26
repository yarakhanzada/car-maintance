import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/profile_controller.dart';
import '../../controller/logout_controller.dart';
import 'EditProfileScreen.dart';
import 'ServiceHistoryScreen.dart';
import 'ComplaintsScreen.dart';
import 'FAQScreen.dart';
import '../../widgets/logout_widget.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final LogoutController logoutController = Get.put(LogoutController());

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = controller.profile.value;

            if (user == null) {
              return const Center(child: Text("No Data"));
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
                    child: Column(
                      children: [
                        _buildProfileHeaderWithLogout(user),
                        const SizedBox(height: 30),
                        _buildSubscriptionCard(width),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionTitle("Account Settings"),
                      _buildMenuTile(
                        Icons.person_outline_rounded,
                        "Edit Profile",
                        "Update your personal data",
                        () async {
                          final result = await Get.to(
                            () => EditProfileScreen(),
                            arguments: user,
                          );
                          if (result == true) {
                            controller.getProfile();
                          }
                        },
                      ),
                      _buildMenuTile(
                        Icons.history_rounded,
                        "Service History",
                        "Check your past car services",
                        () => Get.to(() => const ServiceHistoryScreen()),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Support & Feedback"),
                      _buildMenuTile(
                        Icons.rate_review_outlined,
                        "Complaints & Ratings",
                        "Share your experience with us",
                        () => Get.to(() => const ComplaintsScreen()),
                      ),
                      _buildMenuTile(
                        Icons.help_outline_rounded,
                        "FAQs",
                        "Common questions and answers",
                        () => Get.to(() => const FAQScreen()),
                      ),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderWithLogout(user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE55757), width: 2),
              ),
              child: const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 35, color: Colors.white),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  user.email ?? "",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        LogoutWidget(),
      ],
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned(
      top: -100,
      right: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(double width) {
    return InkWell(
      onTap: () => print("Subscription Card Clicked"),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: width,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.star_rounded,
                size: 150,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "GOLD PACKAGE",
                            style: TextStyle(
                              color: Color(0xFFEF8E8E),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            "Premium Member",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Active",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFFE55757),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "15% Discount on all services",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.02)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF1A1A1A)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
