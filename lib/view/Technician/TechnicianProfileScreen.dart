import 'dart:ui';
import 'package:flutter/material.dart';

class TechnicianProfileScreen extends StatelessWidget {
  const TechnicianProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          _buildTopRedBackground(), 
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildProfileHeader(), 
                  const SizedBox(height: 30),

                 
                  _buildExpertiseBento(),

                  const SizedBox(height: 25),

               
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFF1F2F6),
                child: Icon(
                  Icons.person_rounded,
                  size: 70,
                  color: Colors.black26,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFE55757),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: Colors.white,
                size: 18,
              ), 
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text(
          "Ahmad Al-Mansour",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const Text(
          "Expert Automotive Technician",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildExpertiseBento() {
    return Column(
      children: [
        Row(
          children: [
            _buildBentoBox(
              "Experience",
              "8 Years",
              Icons.history_edu_rounded,
              const Color(0xFFE55757),
            ),
            const SizedBox(width: 15),
            _buildBentoBox(
              "Level",
              "Senior",
              Icons.trending_up_rounded,
              Colors.blueAccent,
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildBentoBoxFull(
          "Main Workshop",
          "Damascuse - Mazzah",
          Icons.location_on_rounded,
          const Color(0xFF1A1A1A),
        ),
      ],
    );
  }

  
  Widget _buildActionList() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          _buildActionItem("Specialization & Skills", Icons.handyman_outlined),
          _buildActionItem("Working Hours", Icons.access_time_rounded),
          _buildActionItem("App Language", Icons.translate_rounded),
          _buildActionItem("Support & Help", Icons.help_outline_rounded),
          const Divider(indent: 20, endIndent: 20),
          _buildActionItem(
            "Logout Account",
            Icons.power_settings_new_rounded,
            isExit: true,
          ),
        ],
      ),
    );
  }

  

  Widget _buildBentoBox(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoBoxFull(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon, {bool isExit = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isExit ? Colors.red.withOpacity(0.1) : const Color(0xFFF1F2F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isExit ? Colors.red : Colors.black87,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isExit ? Colors.red : Colors.black87,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.black26,
      ),
      onTap: () {},
    );
  }

  Widget _buildTopRedBackground() {
    return Positioned(
      top: -150,
      left: 0,
      right: 0,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFFE55757).withOpacity(0.05),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
