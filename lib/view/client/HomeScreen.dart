import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:senior_project/controller/SubscriptionController.dart';
import 'package:senior_project/controller/TowingController.dart';
import 'package:senior_project/controller/VehicleController.dart';
import 'package:senior_project/controller/departmentController.dart';
import 'package:senior_project/controller/profile_controller.dart';
import 'package:senior_project/model/subscriptionModel.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/view/client/ClientNotificationsScreen.dart';
import 'package:senior_project/view/client/MaintenanceRequestScreen.dart';
import 'package:senior_project/view/client/TowingFormScreen.dart';

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

    return Scaffold(
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
              _buildSectionHeader("MONTHLY PACKAGES"),
              _buildPremiumPackagesSlider(width),

              const SizedBox(height: 35),
              _buildSectionHeader("Main DEPARTMENTS"),
              Obx(() => _buildFullImageDepartmentsGrid()),

              const SizedBox(height: 100),
            ],
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
                  : "No car selected";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome back,",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.name ?? "User",
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
              title: "General\nMaintenance",
              subtitle: "Professional care",
              icon: Icons.settings_suggest_rounded,
              color: const Color(0xFF1A1A1A),
              onTap: () => Get.to(
                () => MaintenanceRequestScreen(
                  categoryName: "General Maintenance",
                  categoryId: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildActionCard(
              title: "Emergency\nTowing",
              subtitle: "24/7 Service",
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFFE55757),
              onTap: () => Get.to(() => const TowingFormScreen()),
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
                right: -15,
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
        return const Center(child: Text("No packages available"));
      }

      return CarouselSlider(
        options: CarouselOptions(
          height: 220,
          enlargeCenterPage: true,
          autoPlay: true,
          viewportFraction: 0.85,
        ),
        items: subscriptionController.subscriptions.map((item) {
          List<Color> getGradient() {
            String name = item.name?.toLowerCase() ?? "";
            if (name.contains("silver"))
              return [Colors.blueGrey, Colors.grey.shade400];
            if (name.contains("gold"))
              return [const Color(0xFFFFD700), const Color(0xFFB8860B)];
            if (name.contains("platinum"))
              return [const Color(0xFF232526), Colors.black];
            return [const Color(0xFFE55757), const Color(0xFFB71C1C)];
          }

          return GestureDetector(
            onTap: () => _showCoolSubscriptionSheet(item),
            child: Container(
              width: width,
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: getGradient(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: getGradient()[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Icon(
                        Icons.workspace_premium,
                        size: 160,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (item.name ?? "PLAN").toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              item.description ?? "",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${item.price} SYP",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const CircleAvatar(
                                backgroundColor: Colors.white24,
                                radius: 18,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
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
                        item.name ?? "Subscription Plan",
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
                  "Why join this plan?",
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
                            "Total Price",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          Text(
                            "${item.price} SYP",
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
                      "Confirm & Subscribe",
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

  Widget _buildFullImageDepartmentsGrid() {
    if (deptController.isLoading.value)
      return const Center(child: CircularProgressIndicator());

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
                    errorBuilder: (_, __, ___) => Container(
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
      padding: const EdgeInsets.only(left: 25, bottom: 15),
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
      onTap: () {
        Get.to(() => ClientNotificationsScreen());
      },
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
