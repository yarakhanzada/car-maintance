import 'dart:ui';
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

    return Scaffold(
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
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // تثبيت الهيدر على اليسار دائماً
                  children: [
                    _buildPremiumHeader(), // الهيدر سيبقى مكانه في أعلى اليسار
                    const Expanded(
                      child: Center(
                        // النص التنبيهي فقط هو من سيأخذ منتصف الواجهة بالكامل
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
                              "No completed missions found",
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
                    "$formattedTotalEarnings SP",
                  ),

                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      "COMPLETED MISSIONS & DETAILS",
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
    );
  }

  Widget _buildPremiumHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(25, 30, 25, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ACHIEVEMENTS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE55757),
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Service log",
            style: TextStyle(
              fontSize: 40,
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
            "Total Tasks",
            totalTasksCount,
            Icons.bolt_rounded,
            const Color(0xFFE55757),
          ),
          const SizedBox(width: 15),
          _buildStatCard(
            "Total Processed",
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
        : "Unknown Vehicle";
    String plateNumber = vehicle?.plateNumber ?? "No Plate";
    String customerName = customer?.name ?? "N/A";
    String customerPhone = customer?.phone ?? "N/A";
    String departmentName = dept?.name ?? "General";
    String problemType = serviceReq?.problemType ?? "Normal";

    String engineerNotes = maintenanceReq?.engineerNotes ?? "No engineer notes";
    String techNotes = task.notes;

    String estimatedCost = _formatCurrency(maintenanceReq?.totalEstimatedCost);
    String immediatePremium = _formatCurrency(maintenanceReq?.immediatePremium);
    String finalCost = _formatCurrency(maintenanceReq?.finalTotalCost);

    String taskDuration = "${task.startDate} -> ${task.endDate}";
    String exactExecution =
        "Started: ${maintenanceReq?.startedAt}\nCompleted: ${maintenanceReq?.completedAt}";

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
                "Dept: $departmentName • Est: ${task.estimatedTime} Min",
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
                    "$finalCost SP",
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

            // 1. قسم بيانات الزبون والسيارة
            _buildDetailSectionTitle(
              Icons.person_outline_rounded,
              "CUSTOMER & VEHICLE",
            ),
            _buildDetailRow("Client Name", customerName),
            _buildDetailRow("Client Phone", customerPhone),
            _buildDetailRow("Plate Number", plateNumber),
            _buildDetailRow("Entry Type", problemType),

            const SizedBox(height: 15),

            // 2. قسم تتبع المواعيد والوقت بدقة
            _buildDetailSectionTitle(Icons.access_time_rounded, "TIMELINE LOG"),
            _buildDetailRow("Task Duration", taskDuration),
            _buildDetailRow("Execution", exactExecution, isMultiLine: true),
            _buildDetailRow("Est. Work Time", "${task.estimatedTime} Minutes"),

            const SizedBox(height: 15),

            // 3. قسم الحسابات المالية بالتفصيل للطلب
            _buildDetailSectionTitle(
              Icons.account_balance_wallet_outlined,
              "FINANCIAL RECEIPT",
            ),
            _buildDetailRow("Initial Estimate", "$estimatedCost SP"),
            _buildDetailRow("Immediate Premium", "$immediatePremium SP"),
            _buildDetailRow(
              "Final Total Cost",
              "$finalCost SP",
              isBoldValue: true,
            ),

            const SizedBox(height: 15),

            // 4. قسم الملاحظات والتشخيص المخزن
            _buildDetailSectionTitle(
              Icons.description_outlined,
              "DIAGNOSTIC & NOTES",
            ),
            _buildDetailRow(
              "Engineer Diagnosis",
              engineerNotes,
              isMultiLine: true,
            ),
            _buildDetailRow("Technician Action", techNotes, isMultiLine: true),
            _buildDetailRow("Task Priority Index", "Level ${task.priority}"),
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
              textAlign: TextAlign.end,
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
