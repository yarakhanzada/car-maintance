import 'dart:ui';
import 'package:flutter/material.dart';

class TaskHistoryScreen extends StatelessWidget {
  const TaskHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      body: Stack(
        children: [
          _buildLightArtisticDecor(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumHeader(),
                _buildModernStatsGrid(), 
                const SizedBox(height: 35),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    "COMPLETED MISSIONS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black26,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 110),
                    itemCount: 4,
                    itemBuilder: (context, index) =>
                        _buildPremiumHistoryCard(index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildPremiumHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(25, 30, 25, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ACHIEVEMENTS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE55757),
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Service log",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildModernStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard(
            "Total Tasks",
            "128",
            Icons.bolt_rounded,
            const Color(0xFFE55757),
          ),
          const SizedBox(width: 15),
          _buildStatCard("Rating", "5.0", Icons.star_rounded, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
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
    );
  }


  Widget _buildPremiumHistoryCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2), // حواف بيضاء صريحة
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
       
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.car_repair_rounded,
              color: Color(0xFF1A1A1A),
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Range Rover Sport",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Text(
                  "Full System Diagnostic",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                // ليبل التاريخ
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: const Color(0xFFE55757).withOpacity(0.5),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Yesterday • 4:30 PM",
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(Icons.check, color: Colors.green, size: 16),
          ),
        ],
      ),
    );
  }


  Widget _buildLightArtisticDecor() {
    return Positioned(
      top: -100,
      right: -100,
      child: CircleAvatar(
        radius: 250,
        backgroundColor: const Color(0xFFE55757).withOpacity(0.02),
      ),
    );
  }
}
