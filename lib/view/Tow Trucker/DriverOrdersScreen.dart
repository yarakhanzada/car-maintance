import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/towtrucker%20controller/TowRequestsController.dart';
import 'package:senior_project/controller/towtrucker%20controller/DriverNavigationController.dart';
import 'package:senior_project/controller/client%20controller/profile_controller.dart';

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
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.07,
                    vertical: height * 0.012,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "الطلبات الجديدة",
                        style: TextStyle(
                          color: Color(0xFF1A1D26),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
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
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE55757),
                        ),
                      );
                    }
                    if (ordersCtrl.ordersList.isEmpty) {
                      return const Center(
                        child: Text(
                          "لا توجد طلبات متاحة حالياً",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: ordersCtrl.ordersList.length,
                      padding: EdgeInsets.only(bottom: height * 0.025),
                      itemBuilder: (context, index) {
                        final order = ordersCtrl.ordersList[index];
                        final isExpanded = expandedIndex == index;

                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: width * 0.05,
                            vertical: height * 0.01,
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
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 6,
                                    color: const Color(0xFFE55757),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(width * 0.045),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(width * 0.025),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFEEDEA),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.car_crash,
                                                  color: Color(0xFFE55757),
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      order.customerName ?? "عميل",
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Color(0xFF2D3243),
                                                      ),
                                                    ),
                                                    Text(
                                                      "${order.carBrand} ${order.carModel}",
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => setState(
                                                  () => expandedIndex =
                                                      isExpanded ? null : index,
                                                ),
                                                child: Icon(
                                                  isExpanded
                                                      ? Icons.keyboard_arrow_up_rounded
                                                      : Icons.keyboard_arrow_down_rounded,
                                                  color: const Color(0xFFBDBDBD),
                                                  size: 28,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: Color(0xFF64B5F6),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "يبعد عنك ${order.distanceKm?.toStringAsFixed(1) ?? '0'} كم",
                                                style: const TextStyle(
                                                  color: Color(0xFF90A4AE),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      ordersCtrl.acceptOrder(
                                                    order.towingRequestId,
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFE55757),
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                    ),
                                                    padding: EdgeInsets.symmetric(
                                                      vertical: height * 0.016,
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "قبول الطلب",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                flex: 1,
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      ordersCtrl.rejectOrder(
                                                    order.towingRequestId,
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFF5F5F5),
                                                    foregroundColor:
                                                        const Color(0xFF78909C),
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                    ),
                                                    padding: EdgeInsets.symmetric(
                                                      vertical: height * 0.016,
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "تجاهل",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isExpanded) ...[
                                      const Divider(
                                        height: 1,
                                        indent: 15,
                                        endIndent: 20,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(width * 0.045),
                                        child: Column(
                                          children: [
                                            _buildSmallInfo(
                                              Icons.warning_amber_rounded,
                                              "المشكلة",
                                              (order.problemType ?? "عامة")
                                                  .replaceAll('_', ' '),
                                            ),
                                            _buildSmallInfo(
                                              Icons.fingerprint,
                                              "رقم اللوحة",
                                              order.plateNumber ?? "غير متوفر",
                                            ),
                                            _buildSmallInfo(
                                              Icons.calendar_month,
                                              "سنة الصنع",
                                              order.carYear ?? "غير متوفر",
                                            ),
                                            _buildSmallInfo(
                                              Icons.phone_android,
                                              "رقم الهاتف",
                                              order.customerPhone ?? "غير متوفر",
                                            ),
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
                Text(
                  "مرحباً بك مجدداً،",
                  style: TextStyle(
                    color: const Color(0xFF2D3243).withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                Text(
                  "كابتن ${user?.name ?? "المستخدم"}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Color(0xFF1A1D26),
                  ),
                ),
              ],
            ),
           
          ],
        ),
      );
    });
  }

  Widget _buildBlurBackground(double width, double height) {
    return Stack(
      children: [
        Positioned(
          top: -height * 0.05,
          right: -width * 0.1,
          child: _buildBlurCircle(
            width * 0.7,
            const Color(0xFFE55757).withOpacity(0.06),
          ),
        ),
        Positioned(
          bottom: height * 0.1,
          left: -width * 0.2,
          child: _buildBlurCircle(width * 0.6, Colors.blue.withOpacity(0.04)),
        ),
      ],
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Spacer(),
          Text(
            val,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}