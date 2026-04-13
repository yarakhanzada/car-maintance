import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({super.key});

 
  void _showTaskDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: _buildDetailsContent(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
        
          _buildAmbientDecor(),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: 2, // عدد الطلبات الواردة كمثال
                    itemBuilder: (context, index) => _buildTaskCard(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AVAILABLE MISSIONS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE55757).withOpacity(0.7),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "New Requests",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge("Engine Repair", const Color(0xFFE55757)),
              const Text(
                "2.5 km away",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFF1F2F6),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Colors.black54,
                ),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Yara Mohammad",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  Text(
                    "Audi R8 • Red Color",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  "View Details",
                  Colors.black,
                  Colors.white,
                  () => _showTaskDetails(context),
                ),
              ),
              const SizedBox(width: 12),
              _buildQuickAcceptButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(30),
            children: [
              const Text(
                "Diagnostic Report",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 25),
              _buildDetailInfoBox(
                "The Issue",
                "Unusual sound in the engine upon ignition. Possible oil leak detected near the radiator area.",
                Icons.troubleshoot_rounded,
              ),
              const SizedBox(height: 20),
              _buildDetailInfoBox(
                "Customer Address",
                "Al-Mazzeh, Damascus - Near Golden Mazzeh Hotel",
                Icons.location_on_rounded,
              ),
              const SizedBox(height: 30),
              // الخريطة (Placeholder)
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Icon(
                    Icons.map_rounded,
                    size: 40,
                    color: Colors.black26,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildButton(
                "ACCEPT MISSION",
                const Color(0xFFE55757),
                Colors.white,
                () {
                  Navigator.pop(context);
                  Get.snackbar(
                    "Mission Started",
                    "The task has been moved to In-Progress tab.",
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Decline Request",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildButton(
    String text,
    Color bg,
    Color textCol,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: textCol, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAcceptButton() {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFE55757),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
    );
  }

  Widget _buildDetailInfoBox(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFE55757)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientDecor() {
    return Positioned(
      top: -100,
      left: -100,
      child: CircleAvatar(
        radius: 150,
        backgroundColor: const Color(0xFFE55757).withOpacity(0.03),
      ),
    );
  }
}
