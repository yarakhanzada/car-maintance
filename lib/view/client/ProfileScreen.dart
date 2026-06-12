import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/client controller/SubscriptionController.dart';
import 'package:senior_project/controller/client controller/profile_controller.dart';
import '../../controller/logout_controller.dart';
import 'EditProfileScreen.dart';
import 'ServiceHistoryScreen.dart';
import '../../widgets/logout_widget.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final LogoutController logoutController = Get.put(LogoutController());
  final SubscriptionController subscriptionController = Get.put(
    SubscriptionController(),
  );

  List<Color> _getPlanColors(String planName) {
    String name = planName.toLowerCase();
    if (name.contains("الفضية")) return [Colors.blueGrey, Colors.grey.shade400];
    if (name.contains("الذهبية"))
      return [const Color(0xFFFFD700), const Color(0xFFB8860B)];
    if (name.contains("البلاتينية"))
      return [const Color(0xFF232526), Colors.black];
    return [const Color(0xFFE55757), const Color(0xFFB71C1C)];
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Stack(
          children: [
            _buildBackgroundGradient(),
            Obx(() {
              if (controller.isLoading.value)
                return const Center(child: CircularProgressIndicator());
              final user = controller.profile.value;
              if (user == null)
                return const Center(child: Text("لا توجد بيانات"));
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 70, 25, 20),
                      child: Column(
                        children: [
                          _buildProfileHeader(user),
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
                        _buildSectionTitle("إعدادات الحساب"),
                        _buildMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: "تعديل الملف الشخصي",
                          subtitle: "حدث بياناتك الشخصية",
                          onTap: () async {
                            final result = await Get.to(
                              () => EditProfileScreen(),
                              arguments: user,
                            );
                            if (result == true) controller.getProfile();
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.history_rounded,
                          title: "سجل الخدمات",
                          subtitle: "تحقق من خدمات سيارتك السابقة",
                          onTap: () =>
                              Get.to(() => const ServiceHistoryScreen()),
                        ),
                        const SizedBox(height: 15),
                        _buildSectionTitle("إجراءات"),
                        _buildLogoutTile(),
                        const SizedBox(height: 80),
                      ]),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE55757), width: 2),
          ),
          child: const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, size: 32, color: Colors.white),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name ?? "",
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              user.email ?? "",
              style: const TextStyle(color: Colors.grey, fontSize: 12.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, double width) {
    return Obx(() {
      if (subscriptionController.isLoading.value &&
          subscriptionController.mySubscriptions.isEmpty)
        return const Center(child: CircularProgressIndicator());
      if (subscriptionController.mySubscriptions.isEmpty)
        return _buildEmptySubscription(width);
      final mySub = subscriptionController.mySubscriptions.first;
      final planDetails = mySub?['subscription'];
      if (planDetails == null) return _buildEmptySubscription(width);
      final String planName = (planDetails['name'] ?? "باقة").toString();
      final String discount = (planDetails['discount_percentage'] ?? "0")
          .toString();
      String rawDate = (mySub['end_date'] ?? "").toString();
      String formattedDate = "غير محدد";
      if (rawDate.isNotEmpty) {
        try {
          DateTime dateTime = DateTime.parse(rawDate);
          formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
        } catch (e) {
          formattedDate = "تاريخ غير صالح";
        }
      }
      List<Color> cardColors = _getPlanColors(planName);
      return Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          gradient: LinearGradient(
            colors: cardColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: cardColors[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 20,
              bottom: -15,
              child: Icon(
                Icons.workspace_premium,
                size: 110,
                color: Colors.white.withOpacity(0.1),
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
                      Text(
                        planName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white70,
                        size: 28,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        _buildInfoItem(Icons.percent, "$discount% خصم"),
                        const VerticalDivider(color: Colors.white24, width: 20),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.calendar_today,
                            "ينتهي في: $formattedDate",
                          ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: LogoutWidget()),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "تسجيل الخروج",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  "اخرج من حسابك",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.red, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 12,
          color: Colors.black12,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 5, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black38,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEmptySubscription(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFEEAEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFFE55757),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "لا توجد باقة نشطة",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "اشترك في إحدى باقاتنا المتاحة لفتح الميزات المميزة",
                  style: TextStyle(
                    color: const Color(0xFF2D3243).withOpacity(0.5),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned(
      top: -80,
      left: -40,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.04),
        ),
      ),
    );
  }
}
