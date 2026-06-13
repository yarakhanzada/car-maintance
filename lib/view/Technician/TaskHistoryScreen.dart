import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFE55757),
                      ),
                    ),
                  );
                }

                if (controller.historyTasks.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPremiumHeader(),
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open_rounded,
                                size: 48,
                                color: Colors.black12,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "لا توجد مهام مكتملة",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                double totalEarnings = 0;
                for (var task in controller.historyTasks) {
                  if (task.maintenanceRequest != null) {
                    totalEarnings +=
                        double.tryParse(
                          task.maintenanceRequest!.finalTotalCost,
                        ) ??
                        0;
                  }
                }
                String formattedTotalEarnings = NumberFormat(
                  '#,###',
                ).format(totalEarnings);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPremiumHeader(),
                    _buildModernStatsGrid(
                      controller.historyTasks.length.toString(),
                      "$formattedTotalEarnings ل.س",
                    ),
                    const SizedBox(height: 25),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        "تفاصيل المهام المكتملة",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.black26,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
                        itemCount: controller.historyTasks.length,
                        itemBuilder: (context, index) {
                          final task = controller.historyTasks[index];
                          return _buildPremiumHistoryCard(task);
                        },
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
          Text(
            "الإنجازات",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE55757),
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "سجل الخدمات",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatsGrid(String totalTasksCount, String totalIncome) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard(
            "إجمالي المهام",
            totalTasksCount,
            Icons.bolt_rounded,
            const Color(0xFFE55757),
          ),
          const SizedBox(width: 15),
          _buildStatCard(
            "الأرباح الإجمالية",
            totalIncome,
            Icons.monetization_on_rounded,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 15),
            Text(
              value,
              style: TextStyle(
                fontSize: value.length > 8 ? 18 : 24,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHistoryCard(HistoryTask task) {
    final maintenanceReq = task.maintenanceRequest;
    final serviceReq = maintenanceReq?.serviceRequest;
    final vehicle = serviceReq?.vehicle;
    final customer = serviceReq?.user;
    final dept = task.department;

    String carName = (vehicle != null)
        ? "${vehicle.brand} ${vehicle.model} (${vehicle.year})"
        : "مركبة غير معروفة";
    String plateNumber = vehicle?.plateNumber ?? "لا يوجد لوحة";
    String customerName = customer?.name ?? "غير متوفر";
    String customerPhone = customer?.phone ?? "غير متوفر";
    String departmentName = dept?.name ?? "عام";
    String problemType = serviceReq?.problemType ?? "عادي";
    String engineerNotes = maintenanceReq?.engineerNotes ?? "لا توجد ملاحظات";
    String techNotes = task.notes;
    String estimatedCost = _formatCurrency(maintenanceReq?.totalEstimatedCost);
    String finalCost = _formatCurrency(maintenanceReq?.finalTotalCost);
    String taskDuration = "${task.startDate} -> ${task.endDate}";
    String exactExecution =
        "البدء: ${maintenanceReq?.startedAt}\nالاكتمال: ${maintenanceReq?.completedAt}";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: Color(0xFF1A1A1A),
              size: 26,
            ),
          ),
          title: Text(
            carName,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Color(0xFF1A1A1A),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "القسم: $departmentName • الوقت التقديري: ${task.estimatedTime} دقيقة",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.green),
                  const SizedBox(width: 5),
                  Text(
                    task.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "$finalCost ل.س",
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: const Icon(
            Icons.unfold_more_rounded,
            color: Colors.black38,
          ),
          children: [
            const Divider(color: Color(0xFFF1F3F7), thickness: 1.5),
            const SizedBox(height: 10),
            _buildDetailSectionTitle(
              Icons.person_outline_rounded,
              "العميل والمركبة",
            ),
            _buildDetailRow("اسم العميل", customerName),
            _buildDetailRow("رقم الهاتف", customerPhone),
            _buildDetailRow("رقم اللوحة", plateNumber),
            _buildDetailRow("نوع المشكلة", problemType),
            const SizedBox(height: 15),
            _buildDetailSectionTitle(Icons.access_time_rounded, "سجل الوقت"),
            _buildDetailRow("مدة المهمة", taskDuration),
            _buildDetailRow(
              "التنفيذ الدقيق",
              exactExecution,
              isMultiLine: true,
            ),
            _buildDetailRow("الوقت المقدر", "${task.estimatedTime} دقيقة"),
            const SizedBox(height: 15),
            _buildDetailSectionTitle(
              Icons.account_balance_wallet_outlined,
              "الفاتورة المالية",
            ),
            _buildDetailRow("التكلفة التقديرية", "$estimatedCost ل.س"),
            _buildDetailRow(
              "التكلفة النهائية",
              "$finalCost ل.س",
              isBoldValue: true,
            ),
            const SizedBox(height: 15),
            _buildDetailSectionTitle(
              Icons.description_outlined,
              "التشخيص والملاحظات",
            ),
            _buildDetailRow("تشخيص المهندس", engineerNotes, isMultiLine: true),
            _buildDetailRow("إجراء الفني", techNotes, isMultiLine: true),
            _buildDetailRow("مستوى الأولوية", "المستوى ${task.priority}"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFE55757)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE55757),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBoldValue = false,
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black38,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: isBoldValue ? Colors.green : const Color(0xFF1A1A1A),
                fontSize: 13,
                fontWeight: isBoldValue || isMultiLine
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return "0.00";
    double? parsed = double.tryParse(rawValue);
    if (parsed == null) return rawValue;
    return NumberFormat('#,###').format(parsed);
  }

  Widget _buildLightArtisticDecor() {
    return Positioned(
      top: -100,
      right: -100,
      child: CircleAvatar(
        radius: 250,
        backgroundColor: const Color(0xFFE55757).withOpacity(0.02),
      ),
    );
  }
}
