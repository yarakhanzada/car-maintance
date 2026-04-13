import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/logout_controller.dart';

class LogoutWidget extends StatelessWidget {
  final bool isListTile;

  const LogoutWidget({super.key, this.isListTile = false});

  @override
  Widget build(BuildContext context) {
    final LogoutController controller = Get.put(LogoutController());

    if (isListTile) {
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.power_settings_new_rounded,
            color: Colors.red,
            size: 20,
          ),
        ),
        title: const Text(
          "Logout Account",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.black26,
        ),
        onTap: () => _showLogoutConfirmation(controller),
      );
    }

    return IconButton(
      onPressed: () => _showLogoutConfirmation(controller),
      icon: const Icon(
        Icons.logout_rounded,
        color: Color(0xFFE55757),
        size: 28,
      ),
      tooltip: "Logout",
    );
  }

  void _showLogoutConfirmation(LogoutController controller) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: Colors.black.withOpacity(0.05)),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE55757).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFE55757),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Leaving So Soon?",
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to log out? We'll miss having you here!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(
            bottom: 25,
            left: 20,
            right: 20,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "Stay",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE55757),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
