import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(screenWidth),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  children: [
                    _buildSectionTitle("اليوم"),
                    _buildNotificationItem(
                      title: "وصل السائق للموقع!",
                      message: "سائق سطحة السحب متواجد الآن في موقعك الجغرافي تماماً.",
                      time: "منذ دقيقتين",
                      icon: Icons.local_shipping_rounded,
                      iconBgColor: const Color(0xFFE3F2FD),
                      iconColor: Colors.blue,
                      isUnread: true,
                    ),
                    _buildNotificationItem(
                      title: "تقييم مستوى الخدمة",
                      message: "كيف كانت تجربتك اليوم مع الفني أحمد؟ شاركنا تقييمك.",
                      time: "منذ ساعة",
                      icon: Icons.star_rounded,
                      iconBgColor: const Color(0xFFFFF1F1),
                      iconColor: Colors.orange,
                      isUnread: false,
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

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: const Text(
        "مركز الإشعارات",
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isUnread ? Colors.red.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isUnread ? Colors.red.withOpacity(0.1) : Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (isUnread)
                      Container(
                        height: 8,
                        width: 8,
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}