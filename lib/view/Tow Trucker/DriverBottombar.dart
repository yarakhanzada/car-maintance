import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:senior_project/controller/towtrucker%20controller/DriverNavigationController.dart';
import 'package:senior_project/view/Tow%20Trucker/DriverHistoryScreen.dart';
import 'package:senior_project/view/Tow%20Trucker/DriverMapScreen.dart';
import 'package:senior_project/view/Tow%20Trucker/DriverOrdersScreen.dart';
import 'package:senior_project/view/Tow%20Trucker/DriverProfileScreen.dart';

class DriverBottombar extends StatelessWidget {
  final DriverNavigationController controller = Get.put(
    DriverNavigationController(),
  );

  final List<Widget> screens = [
    DriverOrdersScreen(),
    DriverMapScreen(),
    const DriverHistoryScreen(),
    DriverProfileScreen(),
  ];

   DriverBottombar({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [Obx(() => screens[controller.selectedIndex.value])],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: EdgeInsets.fromLTRB(width * 0.04, 6, width * 0.04, 12),
              child: Obx(
                () => GNav(
                  gap: 6,
                  activeColor: Colors.white,
                  iconSize: 22,
                  tabBackgroundColor: const Color(0xFFE55757).withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  duration: const Duration(milliseconds: 400),
                  color: Colors.white54,
                  selectedIndex: controller.selectedIndex.value,
                  onTabChange: (index) =>
                      controller.selectedIndex.value = index,
                  tabs: const [
                    GButton(icon: Icons.assignment_rounded, text: 'الطلبات'),
                    GButton(icon: Icons.map_rounded, text: 'التتبع'),
                    GButton(icon: Icons.history_rounded, text: 'السجل'),
                    GButton(icon: Icons.person_rounded, text: 'الحساب'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}