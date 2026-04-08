import 'dart:ui';
import 'package:flutter/material.dart';

class ServiceHistoryScreen extends StatelessWidget {
  const ServiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          _buildTopGradient(),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildDynamicHeader(width, context),

                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildServiceCard(index, width),
                      childCount: 10,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicHeader(double width, BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(width * 0.05, 10, width * 0.05, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
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
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Stack(
              children: [
                Text(
                  "SERVICE",
                  style: TextStyle(
                    fontSize: 48,
                    height: 0.8,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1A1A).withOpacity(0.04),
                    letterSpacing: -2,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Service",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -1.5,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          "History",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFFE55757),
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(width: 15),
                        // كبسولة العدد بتصميم زجاجي
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "12 Logs",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(int index, double width) {
    bool isCompleted = index % 3 != 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isCompleted
                  ? Icons.auto_awesome_motion_rounded
                  : Icons.warning_amber_rounded,
              color: isCompleted ? const Color(0xFFE55757) : Colors.orange,
              size: 26,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index % 2 == 0 ? "Battery Jumpstart" : "Oil Change",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "22 March, 2026",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "\$120",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusBadge(isCompleted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isCompleted ? "DONE" : "CANCELED",
        style: TextStyle(
          color: isCompleted ? Colors.green[700] : Colors.red[700],
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTopGradient() {
    return Positioned(
      top: -150,
      left: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.05),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
