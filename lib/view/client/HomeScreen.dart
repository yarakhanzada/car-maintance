import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:senior_project/controller/TowingController.dart';
import 'package:senior_project/controller/VehicleController.dart';
import 'package:senior_project/controller/departmentController.dart';

import 'package:senior_project/controller/profile_controller.dart';
import 'package:senior_project/model/department_model.dart';

import 'package:senior_project/view/client/ClientNotificationsScreen.dart';
import 'package:senior_project/view/client/MaintenanceRequestScreen.dart';

import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/view/client/TowingRequestScreen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ProfileController profileController = Get.put(ProfileController());
  final VehicleController vehicleController = Get.put(VehicleController());
  final DepartmentController deptController = Get.put(DepartmentController());
  final TowingController towingController = Get.put(TowingController());
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.55,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/towtrucker.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                      const Color(0xFFF5F5F7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(screenWidth),
                  SizedBox(height: screenHeight * 0.18),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Quick Emergency",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEmergencyButton(context, screenWidth),
                        const SizedBox(height: 30),
                        const Text(
                          "Main Departments",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Obx(() => _buildServicesList(context, screenWidth)),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(BuildContext context, double width) {
    if (deptController.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE55757)),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: deptController.departments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildServiceCardList(
        context,
        width,
        deptController.departments[index],
      ),
    );
  }

  Widget _buildServiceCardList(
    BuildContext context,
    double width,
    Department dept,
  ) {
    String base = ApiConfig.baseUrl.replaceAll('/api', '');
    String imageUrl =
        "$base${dept.image.startsWith('/') ? dept.image : '/${dept.image}'}";

    return GestureDetector(
      onTap: () => Get.to(
        () => MaintenanceRequestScreen(
          categoryName: dept.name,
          categoryId: dept.id,
        ),
      ),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dept.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: width * 0.55,
                    child: Text(
                      dept.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 15,
              bottom: 15,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 10),
      child: Obx(() {
        final user = profileController.profile.value;
        final vehicles = vehicleController.vehicleList;
        final selectedId = vehicleController.selectedVehicleId.value;
        final selectedVehicle = vehicles.firstWhereOrNull(
          (v) => v.id == selectedId,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFFE55757),
                  child: Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${user?.name ?? "User"}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 10),
                        ],
                      ),
                    ),
                    Text(
                      selectedVehicle != null
                          ? "Vehicle: ${selectedVehicle.brand} ${selectedVehicle.model}"
                          : "No Vehicle Selected",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _buildGlassIconButton(Icons.notifications_none, () {}),
          ],
        );
      }),
    );
  }

  Widget _buildEmergencyButton(BuildContext context, double width) {
    return Obx(
      () => GestureDetector(
        onTap: towingController.isLoading.value
            ? null
            : () => towingController.sendTowingRequest(),
        child: Opacity(
          opacity: towingController.isLoading.value ? 0.6 : 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                height: 90,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE55757).withOpacity(0.2),
                          ),
                        ),
                        towingController.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.local_shipping_rounded,
                                color: Color(0xFFE55757),
                                size: 35,
                              ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Request Tow Truck",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "24/7 Emergency Service",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE55757),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
