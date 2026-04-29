import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/SubscriptionController.dart';

import '../../controller/profile_controller.dart';
import '../../controller/logout_controller.dart';
import 'EditProfileScreen.dart';
import 'ServiceHistoryScreen.dart';
import 'ComplaintsScreen.dart';
import 'FAQScreen.dart';
import '../../widgets/logout_widget.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/SubscriptionController.dart';
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
  final SubscriptionController subscriptionController = Get.put(SubscriptionController());

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
                        _buildSubscriptionCard(context, width),
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

  Widget _buildSubscriptionCard(BuildContext context, double width) {
    return Obx(() {
      if (subscriptionController.isLoading.value &&
          subscriptionController.mySubscriptions.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (subscriptionController.mySubscriptions.isEmpty) {
        return _buildEmptySubscription(width);
      }

      final mySub = subscriptionController.mySubscriptions.first;
      final planDetails = mySub['subscription'];
      final bool isActive = mySub['is_active'] ?? false;

      return Container(
        width: width,
        height: 170,
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
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.stars_rounded,
                size: 100,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
            Positioned(
              top: 35,
              right: 25,
              child: InkWell(
                onTap: () => _showManageSubscriptionSheet(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.settings_suggest_outlined, color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Manage",
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (planDetails['name'] ?? "PLAN").toString().toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFEF8E8E),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Premium Member",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user, color: Color(0xFFE55757), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                "${planDetails['discount_percentage']}% Off on services",
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${planDetails['periodic_inspections_count']} Inspections left",
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? Colors.greenAccent.withOpacity(0.5) : Colors.redAccent.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isActive ? "● Active" : "● Inactive",
                          style: TextStyle(
                            color: isActive ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showManageSubscriptionSheet(BuildContext context) {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text("Manage Subscription", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
              title: const Text("Cancel Subscription", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                _showCancelSubscriptionDialog(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCancelSubscriptionDialog(BuildContext context) {
    if (subscriptionController.mySubscriptions.isEmpty) return;
    final mySub = subscriptionController.mySubscriptions.first;
    final int subscriptionId = mySub['id'];

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancel Subscription", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to cancel your current plan? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Keep Plan", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await subscriptionController.cancelSubscription(subscriptionId);
              await subscriptionController.getMySubscriptions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE55757),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Confirm Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySubscription(double width) {
    return Container(
      width: width,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Text(
          "No active subscription yet.",
          style: TextStyle(color: Colors.grey),
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

  Widget _buildMenuTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}