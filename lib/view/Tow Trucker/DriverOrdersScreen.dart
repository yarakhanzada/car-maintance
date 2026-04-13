import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/DriverNavigationController.dart';

class DriverOrdersScreen extends StatelessWidget {
  const DriverOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<DriverNavigationController>();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      body: Stack(
        children: [
       
          Positioned(
            top: -height * 0.1,
            right: -width * 0.2,
            child: _buildBlurCircle(
              width * 0.8,
              const Color(0xFFE55757).withOpacity(0.15),
            ),
          ),
          Positioned(
            bottom: height * 0.1,
            left: -width * 0.3,
            child: _buildBlurCircle(width * 0.7, Colors.blue.withOpacity(0.1)),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernHeader(navCtrl, width),
                _buildStatusSection(navCtrl, width),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.06,
                    vertical: 10,
                  ),
                  child: Text(
                    "Nearby Requests",
                    style: TextStyle(
                      color: Colors.blueGrey.shade900,
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (!navCtrl.isOnline.value)
                      return _buildOfflineState(width);
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: height * 0.12),
                      itemCount: 3,
                      itemBuilder: (context, index) =>
                          _buildVibrantOrderCard(width),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildModernHeader(DriverNavigationController navCtrl, double width) {
    return Padding(
      padding: EdgeInsets.all(width * 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: width * 0.035,
                ),
              ),
              Text(
                "Captain Ahmed 👋",
                style: TextStyle(
                  color: Colors.blueGrey.shade900,
                  fontSize: width * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: width * 0.06,
              child: Icon(Icons.person_outline, color: const Color(0xFFE55757)),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildStatusSection(DriverNavigationController navCtrl, double width) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.06),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(
            () => CircleAvatar(
              radius: 6,
              backgroundColor: navCtrl.isOnline.value
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Service Status",
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Obx(
            () => Switch.adaptive(
              value: navCtrl.isOnline.value,
              onChanged: (val) => navCtrl.toggleStatus(),
              activeColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildVibrantOrderCard(double width) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // تدرج لوني خفيف على طرف البطاقة
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 5, color: const Color(0xFFE55757)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE55757).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.car_crash_rounded,
                          color: Color(0xFFE55757),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Samer Ali",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: width * 0.045,
                              ),
                            ),
                            const Text(
                              "Highway 5 - Broken Axle",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            "Est. Pay",
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                          Text(
                            "\$45.00",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.blue.shade300,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "2.4 km away from you",
                        style: TextStyle(
                          color: Colors.blueGrey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFancyButton(
                          "Accept Request",
                          const Color(0xFFE55757),
                          true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFancyButton(
                          "Ignore",
                          Colors.grey.shade100,
                          false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFancyButton(String label, Color color, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildOfflineState(double width) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
     
          Container(
            padding: EdgeInsets.all(width * 0.1),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.power_settings_new_rounded,
              size: width * 0.25,
              color: Colors.blueGrey.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            "Ready for a new shift?",
            style: TextStyle(
              color: Colors.blueGrey.shade900,
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Turn on your status to start receiving requests",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey.shade400,
              fontSize: width * 0.035,
            ),
          ),
        ],
      ),
    );
  }
}
