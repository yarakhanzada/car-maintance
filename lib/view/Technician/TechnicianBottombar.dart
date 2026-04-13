import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:senior_project/view/Technician/InProgressTaskScreen.dart';
import 'package:senior_project/view/Technician/NewTasksScreen.dart';
import 'package:senior_project/view/Technician/TaskHistoryScreen.dart';
import 'package:senior_project/view/Technician/TechnicianProfileScreen.dart';


class TechNavigationController extends GetxController {
  var selectedIndex = 0.obs;
}

class TechnicianBottombar extends StatelessWidget {
  final TechNavigationController controller = Get.put(
    TechNavigationController(),
  );

  final List<Widget> screens = [
    const NewTasksScreen(),
    const InProgressTaskScreen(),
    const TaskHistoryScreen(),
    const TechnicianProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() => screens[controller.selectedIndex.value]),

      bottomNavigationBar: Container(
        // نفس التصميم السابق تماماً: انحناء 25 وشفافية 0.6
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
              padding: const EdgeInsets.fromLTRB(
                15,
                6,
                15,
                12,
              ), 
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
            
                  tabs: [
                    const GButton(
                      icon: Icons.bolt_rounded,
                      text: 'New Tasks',
                    ), 
                    const GButton(
                      icon: Icons.build_circle_rounded,
                      text: 'In Progress',
                    ), 
                    const GButton(
                      icon: Icons.history_rounded,
                      text: 'History',
                    ), 
                    const GButton(
                      icon: Icons.person_rounded,
                      text: 'Profile',
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
}
