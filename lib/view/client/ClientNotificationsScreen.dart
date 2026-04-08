import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientNotificationsScreen extends StatelessWidget {
  const ClientNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          _buildArtisticBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfessionalHeader(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const SizedBox(height: 10),
                      _buildSectionHeader("Today"),
                      _buildNotificationItem(
                        icon: Icons.local_shipping_rounded,
                        iconColor: Colors.blue,
                        title: "Driver Arrived!",
                        msg: "Your tow truck driver is now at your location.",
                        time: "2 mins ago",
                        isUnread: true,
                      ),
                      _buildNotificationItem(
                        icon: Icons.star_rounded,
                        iconColor: const Color(0xFFE55757),
                        title: "Rate your trip",
                        msg:
                            "How was your experience with Ahmad? Share your feedback.",
                        time: "1 hour ago",
                        isUnread: true,
                      ),
                      const SizedBox(height: 25),
                      _buildSectionHeader("Yesterday"),
                      _buildNotificationItem(
                        icon: Icons.confirmation_number_rounded,
                        iconColor: Colors.orange,
                        title: "Promo Code Applied",
                        msg:
                            "You saved 5,000 SYP on your last trip using code 'FIRST'.",
                        time: "Yesterday, 4:30 PM",
                        isUnread: false,
                      ),
                      _buildNotificationItem(
                        icon: Icons.security_rounded,
                        iconColor: Colors.green,
                        title: "Security Update",
                        msg: "Your account password was successfully changed.",
                        time: "Yesterday, 10:15 AM",
                        isUnread: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisticBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE55757).withOpacity(0.04),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Stay Updated",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.close_rounded, color: Color(0xFF1A1A1A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 15, top: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String msg,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isUnread ? 0.04 : 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: isUnread
            ? Border.all(color: iconColor.withOpacity(0.1), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          // تفاصيل الإشعار
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (isUnread)
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
                const SizedBox(height: 4),
                Text(
                  msg,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
