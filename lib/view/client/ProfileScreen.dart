import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/client controller/SubscriptionController.dart';
import 'package:senior_project/controller/client controller/profile_controller.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/view/client/SystemSupportScreen.dart';
import '../../controller/logout_controller.dart';
import 'EditProfileScreen.dart';
import '../../widgets/logout_widget.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final LogoutController logoutController = Get.put(LogoutController());
  final SubscriptionController subscriptionController = Get.put(
    SubscriptionController(),
  );


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
                          const SizedBox(height: 40),
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
                          title: "نظام الدعم والمعلومات ",
                          subtitle: "تحقق من نظام الدعم والمعلومات  ",
                          onTap: () =>
                              Get.to(() => const SystemSupportScreen()),
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
    String initial = (user.name != null && user.name.isNotEmpty)
        ? user.name[0].toUpperCase()
        : "U";

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE55757), width: 1),
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE55757),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name ?? "",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE55757).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.email ?? "",
                style: const TextStyle(
                  color: Color(0xFFE55757),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
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
    final planDetails = mySub?['subscription'];

    if (planDetails == null) {
      return _buildEmptySubscription(width);
    }

    final String planName =
        (planDetails['name'] ?? "باقة").toString();
        final imageUrl = (planDetails['image_url'] ?? '').toString();

    String rawDate = (mySub['end_date'] ?? "").toString();
    String formattedDate = "غير محدد";

    if (rawDate.isNotEmpty) {
      try {
        formattedDate = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.parse(rawDate));
      } catch (_) {}
    }
return Container(
  width: width,
  height: 170,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: Stack(
      fit: StackFit.expand,
      children: [
       Image.network(
  "${ApiConfig.base}$imageUrl",
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;

    return const Center(
      child: CircularProgressIndicator(),
    );
  },),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.transparent,
                Colors.black.withOpacity(0.25),
              ],
            ),
          ),
        ),
        Positioned(
  bottom: 29,
  right: 18,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        planName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
             overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 10,
              color: Colors.black,
            ),
          ],
        ),
      ),
      const SizedBox(height: 4),
    ],
  ),
),

        Positioned(
          bottom: 14,
          right: 18,
          child: Text(
            "تنتهي في: $formattedDate",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
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
      top: -50,
      right: -50, 
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.06),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
