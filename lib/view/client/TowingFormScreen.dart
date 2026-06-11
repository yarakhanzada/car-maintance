import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senior_project/controller/client%20controller/TowingController.dart';

class TowingFormScreen extends StatelessWidget {
  const TowingFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TowingController());
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.02),
                        const Text("طلب خدمة مقطورة سحب", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text("الرجاء تحديد البيانات الأساسية لإرسال المقطورة إلى موقعك الحالي", style: TextStyle(color: Colors.grey)),
                        SizedBox(height: height * 0.03),
                        _buildSectionHeader(Icons.directions_car_rounded, "اختر مركبتك من المرأب"),
                        const SizedBox(height: 15),
                        _buildSectionHeader(Icons.location_on_rounded, "تحديد الموقع الجغرافي الحالي"),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: width * 0.05,
              right: width * 0.05,
              child: Obx(() => controller.isLoading.value
                  ? Center(child: LoadingAnimationWidget.staggeredDotsWave(color: const Color(0xFFE55757), size: 50))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE55757),
                        minimumSize: Size(width, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () => controller.sendTowingRequest(),
                      child: const Text("تأكيد وإرسال طلب المقطورة", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    )),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE55757)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}