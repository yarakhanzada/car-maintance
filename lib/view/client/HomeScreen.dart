import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:senior_project/controller/client controller/SubscriptionController.dart';
import 'package:senior_project/controller/client controller/TowingController.dart';
import 'package:senior_project/controller/client controller/VehicleController.dart';
import 'package:senior_project/controller/client controller/departmentController.dart';
import 'package:senior_project/controller/client controller/profile_controller.dart';
import 'package:senior_project/controller/client%20controller/HistoryController.dart';
import 'package:senior_project/model/subscriptionModel.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/token_service.dart';
import 'package:senior_project/view/client/ClientNotificationsScreen.dart';
import 'package:senior_project/view/client/MaintenanceRequestScreen.dart';
import 'package:senior_project/view/client/TowingFormScreen.dart';
import 'package:senior_project/view/client/TowingRequestScreen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ProfileController profileController = Get.put(ProfileController());
  final VehicleController vehicleController = Get.put(VehicleController());
  final DepartmentController deptController = Get.put(DepartmentController());
  final TowingController towingController = Get.put(TowingController());
  final SubscriptionController subscriptionController = Get.put(
    SubscriptionController(),
  );

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFD),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernHeader(),
                const SizedBox(height: 10),
                _buildEnhancedQuickActions(width),
                const SizedBox(height: 35),
                _buildSectionHeader("الباقات الشهرية"),
                _buildPremiumPackagesSlider(width),
                const SizedBox(height: 35),
                _buildSectionHeader("الأقسام الرئيسية"),
                Obx(() => _buildFullImageDepartmentsGrid()),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Obx(() {
              final selectedVehicle = vehicleController.vehicleList
                  .firstWhereOrNull(
                    (v) => v.id == vehicleController.selectedVehicleId.value,
                  );
              final user = profileController.profile.value;
              final carName = selectedVehicle != null
                  ? "${selectedVehicle.brand} ${selectedVehicle.model}"
                  : "لا توجد مركبة مختارة";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "أهلاً بك مجدداً،",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.name ?? "مستخدم",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE55757).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_car_filled_rounded,
                          size: 14,
                          color: Color(0xFFE55757),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          carName,
                          style: const TextStyle(
                            color: Color(0xFFE55757),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          _buildActionCircle(Icons.notifications_none_rounded),
        ],
      ),
    );
  }

  Widget _buildEnhancedQuickActions(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              title: "صيانة\nعامة",
              subtitle: "عناية احترافية",
              icon: Icons.settings_suggest_rounded,
              color: const Color(0xFF1A1A1A),
              onTap: () => Get.to(
                () => MaintenanceRequestScreen(categoryName: "صيانة عامة"),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildActionCard(
              title: "سحب\nطارئ",
              subtitle: "خدمة 24/7",
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFFE55757),
              onTap: () async {
                final currentUserId = await TokenService.getID();

                String? requestString =
                    await TokenService.getActiveRequestForUser(currentUserId);

                if (requestString == null) {
                  Get.to(() => TowingFormScreen());
                  return;
                }

                final historyController = Get.put(HistoryController());

                await historyController.fetchHistory();

                Map<String, dynamic> requestData = jsonDecode(requestString);

                final requestId = requestData['service_request']['id'];
                final request = historyController.requestsList.firstWhereOrNull(
                  (request) => request.id.toString() == requestId.toString(),
                );

                bool exists = request != null && request.status != "completed";

                if (!exists) {
                  await TokenService.clearActiveRequestForCurrentUser();

                  Get.to(() => TowingFormScreen());
                  return;
                }

                Get.to(() => RequestTrackingScreen(requestData: requestData));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Positioned(
                left: -15,
                top: -15,
                child: Icon(
                  icon,
                  size: 100,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPackagesSlider(double width) {
    return Obx(() {
      if (subscriptionController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (subscriptionController.subscriptions.isEmpty) {
        return const Center(child: Text("لا توجد باقات متاحة"));
      }

      return CarouselSlider(
        options: CarouselOptions(
          height: 220,
          enlargeCenterPage: true,
          autoPlay: true,
          viewportFraction: 0.85,
        ),
        items: subscriptionController.subscriptions.map((item) {
          return GestureDetector(
            onTap: () => _showCoolSubscriptionSheet(item),
            child: Container(
              width: width,
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      "${ApiConfig.base}${item.imageUrl}",
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return const Center(child: CircularProgressIndicator());
                      },
                    ),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.85),
                            Colors.black.withOpacity(0.25),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      left: -25,
                      top: -25,
                      child: Icon(
                        Icons.workspace_premium,
                        size: 150,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name ?? "الباقة",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Expanded(
                            child: Text(
                              item.description ?? "",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${item.price} ل.س",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white24,
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  void _showCoolSubscriptionSheet(SubscriptionModel item) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        item.name ?? "باقة اشتراك",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "لماذا تشترك في هذه الباقة؟",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  item.description ?? "",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 25),

                const Text(
                  "مميزات الباقة",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const SizedBox(height: 10),

                ...item.directBenefits.map(
                  (benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(benefit)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "الخصومات",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const SizedBox(height: 10),

                ...item.permanentDiscounts.map(
                  (discount) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.percent,
                          color: Color(0xFFE55757),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(discount)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        Icons.calendar_today,
                        "مدة الاشتراك",
                        "${item.duration} يوم",
                      ),

                      _infoRow(
                        Icons.local_gas_station,
                        "تغيير الزيت",
                        "${item.freeOilChanges} مرات",
                      ),

                      _infoRow(
                        Icons.discount,
                        "خصم أجور اليد",
                        "${item.laborDiscountPercentage}%",
                      ),

                      _infoRow(
                        Icons.build,
                        "خصم قطع الغيار",
                        "${item.partsDiscountPercentage}%",
                      ),

                      _infoRow(
                        Icons.notifications,
                        "تنبيهات العروض",
                        item.includesOfferNotifications == true
                            ? "متوفر"
                            : "غير متوفر",
                      ),

                      _infoRow(
                        Icons.access_time,
                        "تذكير الصيانة",
                        "${item.maintenanceReminderHours} ساعة",
                      ),

                      _infoRow(
                        Icons.verified,
                        "الحالة",
                        item.statusLabel ?? "",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "السعر الإجمالي",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          Text(
                            "${item.price} ل.س",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.verified_user, color: Colors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      subscriptionController.subscribeToPackage(item.id!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "تأكيد والاشتراك",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      barrierColor: Colors.black54,
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE55757), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFullImageDepartmentsGrid() {
    if (deptController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.2,
      ),
      itemCount: deptController.departments.length,
      itemBuilder: (context, index) {
        final dept = deptController.departments[index];
        String baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
        if (!baseUrl.endsWith('/')) baseUrl += '/';
        String imageUrl =
            baseUrl +
            (dept.image.startsWith('/') ? dept.image.substring(1) : dept.image);
        return GestureDetector(
          onTap: () => Get.to(
            () => MaintenanceRequestScreen(
              categoryName: dept.name,
              categoryId: dept.id,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.car_repair),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.85),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      dept.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 25, left: 25, bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildActionCircle(IconData icon) {
    return GestureDetector(
      onTap: () => Get.to(() => ClientNotificationsScreen()),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 24),
      ),
    );
  }
}
