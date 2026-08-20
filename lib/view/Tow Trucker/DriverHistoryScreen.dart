import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/towtrucker%20controller/driver_history_controller.dart';

class DriverHistoryScreen extends StatelessWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DriverHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: Obx(() {
                    if (controller.historyList.isEmpty) {
                      return RefreshIndicator(
                        color: const Color(0xFFE55757),
                        onRefresh: () => controller.fetchHistory(),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(
                              child: Text(
                                "لا توجد طلبات متاحة",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: const Color(0xFFE55757),
                      onRefresh: () => controller.fetchHistory(),
                      child: ListView.builder(
                      itemCount: controller.historyList.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final trip = controller.historyList[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 6,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "${trip.carBrand} ${trip.carModel}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFF2D3243),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                                Text(
                                                  trip.customerName ?? "عميل",
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEEAEA),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.car_crash,
                                              color: Color(0xFFE55757),
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              controller.addressCache[trip.towingRequestId] ?? "تم حفظ الموقع",
                                              style: const TextStyle(
                                                color: Color(0xFF90A4AE),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Color(0xFF64B5F6),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Divider(
                                          color: Color(0xFFF1F3F4),
                                          thickness: 1,
                                          height: 1,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoTag(
                                            Icons.check_circle_outline,
                                            "مكتمل",
                                          ),
                                          _buildInfoTag(
                                            Icons.calendar_month_rounded,
                                            trip.carYear,
                                          ),
                                          _buildInfoTag(
                                            Icons.straighten_rounded,
                                            "${trip.distanceKm} كم",
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
                      },
                      ),
                    );
                  }),
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
      top: -100,
      left: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFE55757).withOpacity(0.08),
              const Color(0xFFF7F7F9).withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 30, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "سجل الرحلات",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1D26),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            "عرض جميع سجلات الخدمات السابقة والمكتملة",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF90A4AE),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Icon(icon, size: 14, color: Colors.grey.shade400),
      ],
    );
  }
}