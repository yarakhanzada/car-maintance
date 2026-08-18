import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/towtrucker%20controller/DriverTowingController.dart';
import 'package:senior_project/controller/towtrucker%20controller/DriverNavigationController.dart';
import 'package:senior_project/widgets/CustomGoogleMapWidget.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<DriverNavigationController>();

    return Obx(() {
      final requestData = navCtrl.activeOrderData.value;

      if (requestData == null) {
        return _buildEmptyState();
      }

      final String requestTag =
          (requestData['id'] ?? requestData['data']?['id'] ?? "0").toString();
      // final s = Get.put(
      //   DriverTowingController(requestData: requestData),
      //   tag: requestTag,
      //   permanent: false,
      // );
      DriverTowingController s;

      if (Get.isRegistered<DriverTowingController>(tag: requestTag)) {
        s = Get.find(tag: requestTag);
      } else {
        s = Get.put(
          DriverTowingController(requestData: requestData),
          tag: requestTag,
        );
      }
      return GetBuilder<DriverTowingController>(
        tag: requestTag,
        builder: (s) {
          LatLng driverLatLng = LatLng(
            s.driverLocation.latitude,
            s.driverLocation.longitude,
          );

          return Scaffold(
            body: Stack(
              children: [
                CustomGoogleMapWidget(
                  driverLocation: driverLatLng,
                  customerLocation: s.customerLocation,
                  routePoints: s.routePoints,
                  isJobStarted: s.isJobStarted,
                  onMapCreated: (ctrl) {
                    _mapController = ctrl;
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(driverLatLng, 15),
                    );
                  },
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: _buildStatusStepper(s),
                ),
                Positioned(
                  bottom: 80,
                  left: 15,
                  right: 15,
                  child: _buildFancyInfoCard(s),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // Empty-state screen widget
  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  size: 80,
                  color: Colors.red[300],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "بانتظار استقبال طلبات جديدة...",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepper(DriverTowingController s) {
    final activeColor = const Color(0xFFE55757);
    final inactiveColor = Colors.white54;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: List.generate(s.statusSequence.length, (index) {
          bool isPastOrCurrent = s.currentStatusIndex >= index;
          Color color = isPastOrCurrent ? activeColor : inactiveColor;

          Widget circleWidget = Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPastOrCurrent ? Colors.white : Colors.white24,
                ),
                child: Icon(
                  s.statusSequence[index]['icon'],
                  color: activeColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.statusSequence[index]['title'],
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );

          if (index < s.statusSequence.length - 1) {
            return Expanded(
              child: Row(
                children: [
                  Expanded(child: circleWidget),
                  Container(
                    width: 30,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: s.currentStatusIndex > index
                        ? activeColor
                        : Colors.white24,
                  ),
                ],
              ),
            );
          } else {
            return Expanded(child: circleWidget);
          }
        }),
      ),
    );
  }

  Widget _buildFancyInfoCard(DriverTowingController s) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.location_on_outlined,
                "${s.distanceToCustomer ?? '--'} كم",
              ),
              Container(height: 25, width: 1, color: Colors.grey[300]),
              _buildStatItem(
                Icons.timer_outlined,
                "${s.estimatedTime ?? '--'} د",
              ),
            ],
          ),
          const Divider(height: 20),
          _buildActionButton(s),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE55757), size: 18),
        const SizedBox(width: 6),
        Text(
          val,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButton(DriverTowingController s) {
    bool isLastStep = s.currentStatusIndex == s.statusSequence.length - 1;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isLastStep
            ? Colors.green[600]
            : const Color(0xFFE55757),
        minimumSize: const Size(double.infinity, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      // onPressed: () async {
      //   if (!s.isJobStarted) {
      //     bool success = await s.startTowing();
      //     if (success) {
      //       Get.snackbar("نجاح", "بدأت المهمة");
      //     }
      //   } else if (!isLastStep) {
      //     String nextStatusKey =
      //         s.statusSequence[s.currentStatusIndex + 1]['key'];
      //     bool apiSuccess = await s.updateTowStatusAPI(nextStatusKey);
      //     if (!apiSuccess) {
      //       Get.snackbar("تنبيه", "فشل تحديث الحالة");
      //     }
      //   } else {
      //     s.completeTowingViaSocket();
      //   }
      // },
      onPressed: () async {
        if (!s.isJobStarted) {
          final message = await s.startTowing();
          if (message == null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(s.driverLocation.latitude, s.driverLocation.longitude),
                16,
              ),
            );
          }
          Get.snackbar(
            message == null ? "نجاح" : "تنبيه",
            message ?? "تمت العملية بنجاح",
            backgroundColor: message == null
                ? Colors.green.withOpacity(0.9)
                : Colors.red.withOpacity(0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else if (!isLastStep) {
          String nextStatusKey =
              s.statusSequence[s.currentStatusIndex + 1]['key'];
          final message = await s.updateTowStatusAPI(nextStatusKey);
          Get.snackbar(
            message == null ? "نجاح" : "تنبيه",
            message ?? "تمت العملية بنجاح",
            backgroundColor: message == null
                ? Colors.green.withOpacity(0.9)
                : Colors.red.withOpacity(0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          // Must go through the socket so the server broadcasts
          // 'tracking_ended' to the customer's room. Calling the REST
          // endpoint directly here leaves the customer stuck on the
          // tracking map since they only ever learn about completion
          // through that socket event.
          s.completeTowingViaSocket();
        }
      },
      child: Text(
        !s.isJobStarted
            ? "بدء المهمة"
            : (isLastStep
                  ? "إنهاء المهمة"
                  : "تحديث: ${s.statusSequence[s.currentStatusIndex + 1]['title']}"),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
