import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:senior_project/controller/technician%20%20controller/taskcontroller.dart';
import 'package:senior_project/view/Technician/InProgressTaskScreen.dart';
import 'package:senior_project/view/Technician/NewTasksScreen.dart';
import 'package:senior_project/view/Technician/TaskHistoryScreen.dart';
import 'package:senior_project/view/Technician/TechNavigationController.dart';
import 'package:senior_project/view/Technician/TechnicianProfileScreen.dart';

class TechnicianBottombar extends StatelessWidget {
  final TechNavigationController controller = Get.put(
    TechNavigationController(),
  );

  final List<Widget> screens = [
    NewTasksScreen(),
    InProgressTaskScreen(),
    TaskHistoryScreen(),
    TechnicianProfileScreen(),
  ];

   TechnicianBottombar({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TaskController(), permanent: true);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        body: Obx(
          () => IndexedStack(
            index: controller.selectedIndex.value,
            children: screens,
          ),
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
                    tabBackgroundColor: const Color(
                      0xFFE55757,
                    ).withOpacity(0.9),
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
                      GButton(icon: Icons.bolt_rounded, text: 'جديدة'),
                      GButton(
                        icon: Icons.build_circle_rounded,
                        text: 'قيد التنفيذ',
                      ),
                      GButton(icon: Icons.history_rounded, text: 'السجل'),
                      GButton(icon: Icons.person_rounded, text: 'الملف'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
