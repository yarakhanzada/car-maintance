import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/TowRequestsController.dart';
import 'package:senior_project/controller/DriverNavigationController.dart';
import 'package:senior_project/controller/profile_controller.dart';

class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final ordersCtrl = Get.put(DriverOrdersController());
    final profileCtrl = Get.put(ProfileController());
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          _buildBlurBackground(width, height),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSimpleHeader(width, profileCtrl),
                Padding(
  padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 10),
  child: Row(
    children: [
      const Text(
        "New Requests",
        style: TextStyle(
          color: Color(0xFF1A1D26), 
          fontSize: 18, 
          fontWeight: FontWeight.w900
        ),
      ),
      const SizedBox(width: 8),
      
      Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFFE55757),
          shape: BoxShape.circle,
        ),
      ),
    ],
  ),
),
                Expanded(
                  child: Obx(() {
                    if (ordersCtrl.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFE55757)));
                    }
                    if (ordersCtrl.ordersList.isEmpty) {
                      return const Center(child: Text("No Requests Available", style: TextStyle(color: Colors.grey)));
                    }

                    return ListView.builder(
                      itemCount: ordersCtrl.ordersList.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        final order = ordersCtrl.ordersList[index];
                        final isExpanded = expandedIndex == index;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                
                                Positioned(
                                  right: 0, top: 0, bottom: 0,
                                  child: Container(width: 6, color: const Color(0xFFE55757)),
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEEAEA),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(Icons.car_crash, color: Color(0xFFE55757), size: 24),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      order.customerName ?? "Client",
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3243)),
                                                    ),
                                                    Text(
                                                      "${order.carBrand} ${order.carModel}",
                                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => setState(() => expandedIndex = isExpanded ? null : index),
                                                child: Icon(
                                                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                                  color: const Color(0xFFBDBDBD),
                                                  size: 28,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 14, color: Color(0xFF64B5F6)),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${order.distanceKm?.toStringAsFixed(1) ?? '0'} km away from you",
                                                style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: ElevatedButton(
                                                  onPressed: () => ordersCtrl.acceptOrder(order.towingRequestId),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFE55757),
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                  ),
                                                  child: const Text("Accept Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                flex: 1,
                                                child: ElevatedButton(
                                                  onPressed: () => ordersCtrl.rejectOrder(order.towingRequestId),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFF5F5F5),
                                                    foregroundColor: const Color(0xFF78909C),
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                  ),
                                                  child: const Text("Ignore", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isExpanded) ...[
                                      const Divider(height: 1, indent: 15, endIndent: 20),
                                      Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Column(
                                          children: [
                                            _buildSmallInfo(Icons.warning_amber_rounded, "Problem", (order.problemType ?? "General").replaceAll('_', ' ')),
                                            _buildSmallInfo(Icons.fingerprint, "Chassis", order.chassisNumber ?? "N/A"),
                                            _buildSmallInfo(Icons.calendar_month, "Year", order.carYear ?? "N/A"),
                                            _buildSmallInfo(Icons.phone_android, "Phone", order.customerPhone ?? "N/A"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _buildSimpleHeader(double width, ProfileController profileCtrl) {
    return Obx(() {
      final user = profileCtrl.profile.value;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back,", style: TextStyle(color:  const Color(0xFF2D3243).withOpacity(0.6), fontSize: 14)),
                Text(
                  "Captain ${user?.name ?? "User"}",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color:  Color(0xFF1A1D26),),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: const Icon(Icons.notifications_none_rounded,  color: Colors.black, size: 24,),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBlurBackground(double width, double height) {
    return Stack(
      children: [
        Positioned(top: -height * 0.05, right: -width * 0.1, child: _buildBlurCircle(width * 0.7, const Color(0xFFE55757).withOpacity(0.06))),
        Positioned(bottom: height * 0.1, left: -width * 0.2, child: _buildBlurCircle(width * 0.6, Colors.blue.withOpacity(0.04))),
      ],
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
    );
  }

  Widget _buildSmallInfo(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Spacer(),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}