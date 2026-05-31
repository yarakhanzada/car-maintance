import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/client%20controller/HistoryController.dart';
import 'package:senior_project/model/ServiceHistoryModel.dart';

class ServiceHistoryScreen extends StatelessWidget {
  const ServiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          _buildTopGradient(),
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE55757)),
                );
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildDynamicHeader(
                    width,
                    context,
                    controller.requestsList.length,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = controller.requestsList[index];
                        return _buildServiceCard(context, item, width);
                      }, childCount: controller.requestsList.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- Header ---
  Widget _buildDynamicHeader(double width, BuildContext context, int count) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(width * 0.05, 10, width * 0.05, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),

              child: Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white,

                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),

                      blurRadius: 15,
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.arrow_back_ios_new,

                  size: 16,

                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Stack(
              children: [
                Text(
                  "SERVICE",

                  style: TextStyle(
                    fontSize: 48,

                    height: 0.8,

                    fontWeight: FontWeight.w900,

                    color: const Color(0xFF1A1A1A).withOpacity(0.04),

                    letterSpacing: -2,
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Service",

                      style: TextStyle(
                        fontSize: 40,

                        fontWeight: FontWeight.w900,

                        color: Color(0xFF1A1A1A),

                        letterSpacing: -1.5,
                      ),
                    ),

                    Row(
                      children: [
                        const Text(
                          "History",

                          style: TextStyle(
                            fontSize: 40,

                            fontWeight: FontWeight.w300,

                            color: Color(0xFFE55757),

                            letterSpacing: -1.5,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,

                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),

                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: Text(
                            "$count Logs",

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 10,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Card ---
  Widget _buildServiceCard(
    BuildContext context,
    ServiceData item,
    double width,
  ) {
    bool isTowing = item.problemType == "towing";

    return GestureDetector(
      onTap: () => _showDetailsSheet(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
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
            _buildIconTile(isTowing),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTowing ? "Towing Service" : "Maintenance",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    "${item.vehicle?.brand} ${item.vehicle?.model}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.createdAt?.split('T')[0] ?? "",
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(item.status ?? "New"),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTile(bool isTowing) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        isTowing ? Icons.local_shipping_rounded : Icons.build_circle_rounded,
        color: const Color(0xFFE55757),
        size: 26,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == "assigned"
        ? Colors.blue
        : (status == "new" ? Colors.orange : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // --- Bottom Sheet  ---
  void _showDetailsSheet(BuildContext context, ServiceData item) {
    bool isTowing = item.problemType == "towing";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              isTowing ? "Towing Details" : "Maintenance Details",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 40),

            // معلومات السيارة
            _infoRow(
              Icons.directions_car,
              "Vehicle",
              "${item.vehicle?.brand} ${item.vehicle?.model} (${item.vehicle?.year})",
            ),
            _infoRow(
              Icons.fingerprint,
              "Chassis",
              item.vehicle?.chassisNumber ?? "N/A",
            ),

            if (isTowing) ...[
              const SizedBox(height: 15),
              _infoRow(
                Icons.map_outlined,
                "Distance",
                "${item.towingRequest?.distance} KM",
              ),
              _infoRow(
                Icons.location_on,
                "Coordinates",
                "${item.towingRequest?.location?.latitude}, ${item.towingRequest?.location?.longitude}",
              ),
              if (item.towingRequest?.towTruck != null)
                _infoRow(
                  Icons.person,
                  "Driver Truck ID",
                  "#${item.towingRequest?.towTruck?.id} (Price: ${item.towingRequest?.towTruck?.pricePerKm}/km)",
                ),
            ],

            if (!isTowing) ...[
              const SizedBox(height: 15),
              _infoRow(
                Icons.event,
                "Scheduled Date",
                item.maintenanceRequest?.scheduledDate ?? "Not set",
              ),
              _infoRow(
                Icons.info_outline,
                "Status",
                "Request is currently ${item.status}",
              ),
            ],

            const SizedBox(height: 20),
            const Text(
              "History Timeline",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: item.requestStatusHistory?.length ?? 0,
                itemBuilder: (context, i) {
                  final hist = item.requestStatusHistory![i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    title: Text(
                      "Status changed to ${hist.status}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      hist.changedAt?.split('T')[1].substring(0, 5) ?? "",
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFE55757)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopGradient() {
    return Positioned(
      top: -150,
      left: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.05),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
