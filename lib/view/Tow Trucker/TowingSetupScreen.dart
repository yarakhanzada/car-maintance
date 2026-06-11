import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/view/Tow%20Trucker/DriverBottombar.dart';

class TowingSetupScreen extends StatelessWidget {
  const TowingSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/towtrucker.jpg'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 6.0,
                sigmaY: 6.0,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.08),
                  _buildPremiumHeader(screenWidth),
                  SizedBox(height: screenHeight * 0.05),
                  _buildPremiumDataCard(screenWidth),
                  SizedBox(height: screenHeight * 0.06),
                  _buildGlowButton(screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "تسجيل الأسطول",
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFE55757),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "بطاقة تعريف المركبة",
          style: TextStyle(
            fontSize: screenWidth * 0.085,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "هذه التفاصيل ستظهر للعميل الخاص بك.",
          style: TextStyle(
            color: Colors.white60, 
            fontSize: screenWidth * 0.038
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumDataCard(double screenWidth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.07),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildInputFieldRow(
                Icons.pin_rounded,
                "رقم اللوحة",
                "أ - 99102",
                screenWidth,
                isPlate: true,
              ),
              const Divider(color: Colors.white10, height: 40),
              _buildInputFieldRow(
                Icons.local_shipping_rounded,
                "موديل الشاحنة",
                "جي إم سي سافانا / إيسوزو",
                screenWidth,
              ),
              const Divider(color: Colors.white10, height: 40),
              _buildInputFieldRow(
                Icons.color_lens_rounded,
                "لون المركبة",
                "أصفر فاقع",
                screenWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldRow(
    IconData icon,
    String label,
    String hint,
    double screenWidth, {
    bool isPlate = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE55757), size: screenWidth * 0.06),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.028,
                  fontWeight: FontWeight.w900,
                  color: Colors.white60,
                  letterSpacing: 1,
                ),
              ),
              TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                  letterSpacing: isPlate ? 3 : 0,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlowButton(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE55757).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () => Get.offAll(() => DriverBottombar()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE55757),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: Text(
            "حفظ والدخول أونلاين",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: screenWidth * 0.042,
            ),
          ),
        ),
      ),
    );
  }
}