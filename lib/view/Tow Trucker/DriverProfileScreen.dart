import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/profile_client_controller.dart';
import 'package:senior_project/widgets/logout_widget.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          _buildVisualBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildModernHeader(),
                  const SizedBox(height: 30),
                  _buildHeroProfileCard(),
                  const SizedBox(height: 25),
                  _buildBentoGridSection(),
                  const SizedBox(height: 30),
                  const Text(
                    "Quick Management",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE55757).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.05),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Account",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              "Profile",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderCircleBtn(
              Icons.notifications_none_rounded,
              Colors.black87,
            ),
            const SizedBox(width: 12),
            const LogoutWidget(),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCircleBtn(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: () {},
      ),
    );
  }

  Widget _buildHeroProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFE55757), Color(0xFFEF8E8E)],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFFF5F5F7),
                  child: Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Icon(Icons.check_circle, color: Colors.blue, size: 18),
              ),
            ],
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ahmad Al-Hussein",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Certified Tow Driver",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGridSection() {
    return SizedBox(
      height: 190,
      child: Row(
        children: [
          // Wallet Card
          Expanded(
            flex: 3,
            child: _buildBentoBox(
              color: const Color(0xFF1A1A1A),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "BALANCE",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "150,000",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    "SYP",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Withdraw",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Stats Column
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: _buildBentoBox(
                    color: const Color(0xFFE55757).withOpacity(0.1),
                    child: _buildSmallStat(
                      Icons.star_rounded,
                      "4.9",
                      "Rating",
                      const Color(0xFFE55757),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildBentoBox(
                    color: Colors.blue.withOpacity(0.08),
                    child: _buildSmallStat(
                      Icons.local_shipping_rounded,
                      "142",
                      "Trips",
                      Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoBox({required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }

  Widget _buildSmallStat(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionList() {
    return Column(
      children: [
        _buildSettingsTile(
          Icons.minor_crash_rounded,
          "Truck Details",
          "Manage your GMC Flatbed 2022",
        ),
        _buildSettingsTile(
          Icons.history_rounded,
          "Trip History",
          "Review your completed services",
        ),
        _buildSettingsTile(
          Icons.contact_support_rounded,
          "Help Center",
          "FAQs and direct support",
        ),
        _buildSettingsTile(
          Icons.settings_outlined,
          "App Settings",
          "Notifications and dark mode",
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FD),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey.shade400,
        ),
        onTap: () {},
      ),
    );
  }
}
