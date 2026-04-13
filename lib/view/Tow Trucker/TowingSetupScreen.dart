import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/view/Tow%20Trucker/DriverBottombar.dart';

class TowingSetupScreen extends StatelessWidget {
  const TowingSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              ), // طبقة تعتيم إضافية
            ),
          ),

       
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),

                
                  _buildPremiumHeader(),

                  const SizedBox(height: 50),

                 
                  _buildPremiumDataCard(),

                  const SizedBox(height: 60),

            
                  _buildGlowButton(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "FLEET REGISTRATION,",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Color(0xFFE55757),
            letterSpacing: 3,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Vehicle ID Card",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        Text(
          "These details will be shown to your customer.",
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }


  Widget _buildPremiumDataCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
        
              _buildInputFieldRow(
                Icons.pin_rounded,
                "PLATE NUMBER",
                "A-99102",
                isPlate: true,
              ),
              const Divider(color: Colors.white10, height: 40),

              _buildInputFieldRow(
                Icons.local_shipping_rounded,
                "TRUCK MODEL",
                "GMC Savana / Isuzu",
              ),
              const Divider(color: Colors.white10, height: 40),

              _buildInputFieldRow(
                Icons.color_lens_rounded,
                "VEHICLE COLOR",
                "Bright Yellow",
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
    String hint, {
    bool isPlate = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE55757), size: 24),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white60,
                  letterSpacing: 1.5,
                ),
              ),
              TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: isPlate
                      ? 3
                      : 0,
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


  Widget _buildGlowButton() {
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
          onPressed: () =>
              Get.offAll(() => DriverBottombar()), 
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE55757),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: const Text(
            "SAVE & GO ONLINE",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
