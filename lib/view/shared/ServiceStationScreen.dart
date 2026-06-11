import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/view/shared/LoginScreen.dart';

class ServiceStationScreen extends StatelessWidget {
  const ServiceStationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery لتحديد أبعاد الشاشة والاستجابة
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/startscreen.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.08),
                  // العنوان الرئيسي
                  const Text(
                    'محطة الخدمة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // العنوان الفرعي
                  const Text(
                    'الحل الأمثل لجميع خدمات صيانة مركبتك',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const Spacer(),
                  SizedBox(
                    width: screenWidth * 0.45,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE55757),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "لنبدأ الآن",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}