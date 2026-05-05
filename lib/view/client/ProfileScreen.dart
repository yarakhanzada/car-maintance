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
import 'package:intl/intl.dart';

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
    if (mySub == null) return _buildEmptySubscription(width);

    final planDetails = mySub['subscription'];
    final bool isActive = mySub['is_active'] ?? false;

    if (planDetails == null) return _buildEmptySubscription(width);

    final String planName = (planDetails['name'] ?? "Plan").toString();
    final String discount = (planDetails['discount_percentage'] ?? "0").toString();
    String rawDate = (mySub['end_date'] ?? "").toString();
String formattedDate = "N/A";

if (rawDate.isNotEmpty) {
  try {
    DateTime dateTime = DateTime.parse(rawDate);
    formattedDate = DateFormat('yyyy-MM-dd').format(dateTime); 
  } catch (e) {
    formattedDate = "Invalid Date";
  }
}

final String inspections = formattedDate;

    return Container(
      width: width,
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF232526),
            const Color(0xFF414345),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF8E8E).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -15,
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 110,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planName.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFEF8E8E),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                       
                      ],
                    ),
                    const Icon(Icons.auto_awesome, color: Color(0xFFEF8E8E), size: 28),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      _buildInfoItem(Icons.percent, "$discount% Off"),
                      const VerticalDivider(color: Colors.white24, indent: 5, endIndent: 5),
Expanded(
      child: _buildInfoItem(Icons.calendar_today, "Ends: $formattedDate"),
    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

Widget _buildInfoItem(IconData icon, String label) {
  return Row(
    children: [
      Icon(icon, color: const Color(0xFFEF8E8E), size: 16),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
      ),
      const SizedBox(width: 15),
    ],
  );
}
Widget _buildStatusIndicator(bool isActive) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isActive ? Colors.greenAccent : Colors.redAccent,
        width: 0.5,
      ),
    ),
    child: Text(
      isActive ? "ACTIVE" : "INACTIVE",
      style: TextStyle(
        color: isActive ? Colors.greenAccent : Colors.redAccent,
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}Widget _buildEmptySubscription(double width) {
  return Container(
    width: width,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE55757).withOpacity(0.15),
                const Color(0xFFE55757).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
          Icons.account_balance_wallet_rounded, 
            color: Color(0xFFE55757),
            size: 28,
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "No Active Plan",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Subscribe to one of our available plans to unlock premium features",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
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