import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:senior_project/view/client/BookingsScreen.dart';
import 'package:senior_project/view/client/Chatbot.dart';
import 'package:senior_project/view/client/HomeScreen.dart';
import 'package:senior_project/view/client/MyGarageScreen.dart';
import 'package:senior_project/view/client/ProfileScreen.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;
}

class ClientBottombar extends StatelessWidget {
  final NavigationController controller = Get.put(NavigationController());

  final List<Widget> screens = [
    const HomeScreen(),
    const BookingsScreen(),

    const MyGarageScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Obx(() => screens[controller.selectedIndex.value]),

          Positioned(
            bottom: 110,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Get.to(() => ChatBotScreen());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFE55757),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
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
              padding: const EdgeInsets.fromLTRB(15, 6, 15, 12),
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
                    GButton(icon: Icons.home_rounded, text: 'Home'),
                    GButton(
                      icon: Icons.calendar_today_rounded,
                      text: 'Bookings',
                    ),
                    GButton(icon: Icons.directions_car_rounded, text: 'Garage'),
                    GButton(icon: Icons.person_rounded, text: 'Profile'),
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
