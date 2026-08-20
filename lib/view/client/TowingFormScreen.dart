import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senior_project/controller/client controller/TowingController.dart';

class TowingFormScreen extends StatelessWidget {
  const TowingFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TowingController());
    final double width = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            _buildBackground(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildStyleHeader(width),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.06,
                    vertical: 10,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopStatusCard(),
                      const SizedBox(height: 25),
                      _buildSectionHeader(
                        Icons.directions_car_filled_rounded,
                        "اختر مركبتك",
                      ),
                      _buildVehicleSelector(controller),
                      const SizedBox(height: 25),
                      _buildSectionHeader(
                        Icons.report_problem_rounded,
                        "وصف المشكلة",
                      ),
                      _buildModernTextField(controller),
                      const SizedBox(height: 20),
                      _buildSectionHeader(
                        Icons.tips_and_updates_rounded,
                        "نصائح مهمة",
                      ),
                      _buildTipsCard(),
                      const SizedBox(height: 40),
                      _buildSubmitButton(controller),
                      const SizedBox(height: 50),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFE55757)),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• شغل أضواء التحذير", style: TextStyle(fontSize: 13)),
          SizedBox(height: 8),
          Text("• ابقَ بالقرب من السيارة", style: TextStyle(fontSize: 13)),
          SizedBox(height: 8),
          Text(
            "• لا تحاول تشغيل السيارة إذا كان العطل خطيراً",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      left: -100,
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildStyleHeader(double width) {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(width * 0.06, 20, width * 0.06, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "سحب طارئ",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "احصل على مساعدة احترافية على الطريق الآن",
                style: TextStyle(color: Colors.grey[500], fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatusCard() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool locationEnabled = false;

        Future<void> checkLocation() async {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

          if (serviceEnabled) {
            setState(() {
              locationEnabled = true;
            });
          } else {
            await Geolocator.openLocationSettings();
          }
        }

        return StatefulBuilder(
          builder: (context, update) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE55757).withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: locationEnabled
                          ? Colors.green.withOpacity(0.12)
                          : const Color(0xFFFFEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      locationEnabled ? Icons.my_location : Icons.location_on,
                      color: locationEnabled
                          ? Colors.green
                          : const Color(0xFFE55757),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationEnabled ? "تم تحديد الموقع" : "موقع الـ GPS",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          locationEnabled
                              ? "موقعك جاهز لإرسال طلب السحب"
                              : "فعّل الموقع لتحديد مكان وصول خدمة السحب",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  locationEnabled
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : TextButton(
                          onPressed: () async {
                            bool enabled =
                                await Geolocator.isLocationServiceEnabled();

                            if (!enabled) {
                              await Geolocator.openLocationSettings();
                            }

                            bool after =
                                await Geolocator.isLocationServiceEnabled();

                            if (after) {
                              update(() {
                                locationEnabled = true;
                              });
                            }
                          },
                          child: const Text(
                            "تفعيل",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE55757),
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE55757)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelector(TowingController controller) {
    return Obx(() {
      if (controller.userVehicles.isEmpty) {
        return _buildNoVehicleCard(controller);
      }

      return Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
          ],
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            hint: const Text("اختر المركبة", style: TextStyle(fontSize: 14)),
            value: controller.selectedVehicleId.value,
            icon: const Icon(
              Icons.expand_more_rounded,
              color: Color(0xFFE55757),
            ),
            items: controller.userVehicles.map((vehicle) {
              return DropdownMenuItem<int>(
                value: vehicle.id,
                child: Text(
                  "${vehicle.brand} ${vehicle.model} (${vehicle.plate_number})",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              controller.selectedVehicleId.value = value;
            },
          ),
        ),
      );
    });
  }

  Widget _buildNoVehicleCard(TowingController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE55757).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_car_filled_outlined,
                  color: Colors.grey[500],
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "لا توجد مركبات مسجلة في مرأبك بعد",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                controller.goToGarageToAddVehicle();
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text(
                "إضافة مركبة",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE55757),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField(TowingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: TextField(
        controller: controller.problemController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "اكتب وصفاً مختصراً للمشكلة...",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(TowingController controller) {
    return Obx(
      () => controller.isLoading.value
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: const Color(0xFFE55757),
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "جاري معالجة طلبك...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE55757),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: const Color(0xFFE55757).withOpacity(0.3),
              ),
              onPressed: () {
                controller.sendTowingRequest();
              },
              child: const Text(
                "تأكيد الطلب",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
    );
  }
}
