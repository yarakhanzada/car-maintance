import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/technician  controller/TechnicianHistoryController.dart';
import 'package:senior_project/model/technician model/TechnicianHistoryModel.dart';
class TaskHistoryScreen extends StatelessWidget {
  const TaskHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TechnicianHistoryController());

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Stack(
          children: [
            _buildLightArtisticDecor(),
            SafeArea(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE55757))));
                }

                if (controller.historyTasks.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPremiumHeader(),
                      const Expanded(child: Center(child: Text("لا توجد مهام مكتملة", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold)))),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPremiumHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSingleStatCard(
                        "إجمالي المهام المنجزة",
                        controller.historyTasks.length.toString(),
                        Icons.history_edu_rounded,
                        const Color(0xFFE55757),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28),
                      child: Text("سجل النشاطات", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black26, letterSpacing: 2)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
                        itemCount: controller.historyTasks.length,
                        itemBuilder: (context, index) => _buildPremiumHistoryCard(controller.historyTasks[index]),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(25, 30, 25, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("الإنجازات", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFE55757), letterSpacing: 2)),
          SizedBox(height: 8),
          Text("سجل الخدمات", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A), height: 1)),
        ],
      ),
    );
  }

  Widget _buildSingleStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildPremiumHistoryCard(HistoryTask task) {
    final maintenanceReq = task.maintenanceRequest;
    final serviceReq = maintenanceReq?.serviceRequest;
    final vehicle = serviceReq?.vehicle;
    final customer = serviceReq?.user;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.directions_car_filled_rounded, color: Color(0xFF1A1A1A), size: 26),
          ),
          title: Text("${vehicle?.brand ?? ''} ${vehicle?.model ?? ''}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
         subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "القسم: ${task.department?.name ?? 'عام'} , الوقت المقدر: ${maintenanceReq?.estimatedDurationMinutes ?? '0'} دقيقة",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.green),
                  const SizedBox(width: 5),
                  Text(
                     task.status.toUpperCase(),
                    style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(color: Color(0xFFF1F3F7), thickness: 1.5),
            _buildDetailSectionTitle(Icons.person_outline_rounded, "معلومات العميل والمركبة"),
            _buildDetailRow("اسم العميل", customer?.name ?? "-"),
            _buildDetailRow("رقم اللوحة", vehicle?.plateNumber ?? "-"),
            _buildDetailRow("نوع المشكلة", serviceReq?.problemType ?? "-"),
            _buildDetailSectionTitle(Icons.access_time_rounded, "سجل الوقت"),
            _buildDetailRow("بدء العمل", task.startDate ?? "-"),
            _buildDetailRow("انتهى في", task.endDate ?? "-"),
            _buildDetailRow("الوقت المقدر", "${maintenanceReq?.estimatedDurationMinutes ?? '0'} دقيقة"),
            _buildDetailSectionTitle(Icons.description_outlined, "ملاحظات"),
            _buildDetailRow("تشخيص المهندس", maintenanceReq?.engineerNotes ?? "-"),
            _buildDetailRow("إجراء الفني", task.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFE55757)),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFE55757), letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildLightArtisticDecor() {
    return Positioned(top: -100, right: -100, child: CircleAvatar(radius: 250, backgroundColor: const Color(0xFFE55757).withOpacity(0.02)));
  }
}