import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senior_project/controller/logout_controller.dart';
import 'package:senior_project/controller/technician%20%20controller/technician_profile_controller.dart';
import 'package:senior_project/widgets/logout_widget.dart';

class TechnicianProfileScreen extends StatelessWidget {
  const TechnicianProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TechnicianProfileController profileController = Get.put(TechnicianProfileController());
    final LogoutController logoutController = Get.put(LogoutController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: Stack(
          children: [
            _buildTopRedBackground(),
            SafeArea(
              child: Obx(() {
                if (profileController.isLoading.value) {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(color: const Color(0xFFE55757), size: 50),
                  );
                }
                final data = profileController.profileData.value;
                if (data == null) {
                  return const Center(child: Text("لا توجد بيانات شخصية"));
                }
                return RefreshIndicator(
                  onRefresh: () => profileController.fetchProfile(),
                  color: const Color(0xFFE55757),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildProfileHeader(data),
                        const SizedBox(height: 25),
                        _buildExpertiseBento(data),
                        const SizedBox(height: 20),
                        _buildActionList(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic data) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const CircleAvatar(radius: 60, backgroundColor: Color(0xFFF1F2F6), child: Icon(Icons.person_rounded, size: 70, color: Colors.black26))),
            Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFE55757), shape: BoxShape.circle), child: const Icon(Icons.verified_rounded, color: Colors.white, size: 18)),
          ],
        ),
        const SizedBox(height: 15),
        Text(data.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        Text("القسم: ${data.department?.name ?? 'عام'}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildExpertiseBento(dynamic data) {
    Color statusColor = data.availabilityStatus == "busy" ? Colors.orange : Colors.green;
    return Column(
      children: [
        Row(
          children: [
            _buildBentoBox("إجمالي المهام", "${data.tasksSummary?.total ?? 0}", Icons.assignment_rounded, const Color(0xFFE55757)),
            const SizedBox(width: 15),
            _buildBentoBox("المكتملة", "${data.tasksSummary?.completed ?? 0}", Icons.task_alt_rounded, Colors.green),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildBentoBox("قيد التنفيذ", "${data.tasksSummary?.active ?? 0}", Icons.bolt_rounded, Colors.blueAccent),
            const SizedBox(width: 15),
            _buildBentoBox("الحالة", "${data.availabilityStatus == 'busy' ? 'مشغول' : 'متاح'}".toUpperCase(), Icons.hourglass_empty_rounded, statusColor),
          ],
        ),
        const SizedBox(height: 12),
        _buildBentoBoxFull("البريد الإلكتروني", data.email, Icons.email_rounded, const Color(0xFF1A1A1A)),
        const SizedBox(height: 12),
        _buildBentoBoxFull("رقم الهاتف", data.phone, Icons.phone_android_rounded, Colors.blueGrey),
        const SizedBox(height: 12),
        _buildBentoBoxFull("عضو منذ", "${data.memberSince.split('T')[0]}", Icons.calendar_month_rounded, Colors.deepPurple),
      ],
    );
  }

  Widget _buildActionList() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
      child: const Column(children: [LogoutWidget(isListTile: true)]),
    );
  }

  Widget _buildBentoBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoBoxFull(String label, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRedBackground() {
    return Positioned(top: -150, left: 0, right: 0, child: Container(height: 400, decoration: BoxDecoration(color: const Color(0xFFE55757).withOpacity(0.05), shape: BoxShape.circle)));
  }
}