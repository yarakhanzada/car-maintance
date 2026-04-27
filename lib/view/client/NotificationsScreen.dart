import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildSectionTitle("Today"),
                  _buildNotificationItem(
                    title: "Driver Arrived!",
                    message: "Your tow truck driver is now at your location.",
                    time: "2 mins ago",
                    icon: Icons.local_shipping_rounded,
                    iconBgColor: const Color(0xFFE3F2FD),
                    iconColor: Colors.blue,
                    isUnread: true,
                  ),
                  _buildNotificationItem(
                    title: "Rate your trip",
                    message:
                        "How was your experience with Ahmad? Share your feedback.",
                    time: "1 hour ago",
                    icon: Icons.star_rounded,
                    iconBgColor: const Color(0xFFFFF1F1),
                    iconColor: Colors.redAccent,
                    isUnread: true,
                  ),

                  const SizedBox(height: 25),
                  _buildSectionTitle("Yesterday"),
                  _buildNotificationItem(
                    title: "Promo Code Applied",
                    message:
                        "You saved 5,000 SYP on your last trip using code 'FIRST'.",
                    time: "Yesterday, 4:30 PM",
                    icon: Icons.confirmation_number_rounded,
                    iconBgColor: const Color(0xFFFFF8E1),
                    iconColor: Colors.orange,
                    isUnread: false,
                  ),
                  _buildNotificationItem(
                    title: "Security Update",
                    message: "Your account password was successfully changed.",
                    time: "Yesterday, 10:15 AM",
                    icon: Icons.security_rounded,
                    iconBgColor: const Color(0xFFE8F5E9),
                    iconColor: Colors.green,
                    isUnread: false,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Stay Updated",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10, left: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 16),

          // محتوى النص
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        height: 8,
                        width: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
