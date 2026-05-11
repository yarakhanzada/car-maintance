import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/DriverTowingController.dart';
import 'package:senior_project/controller/DriverNavigationController.dart';
import 'package:senior_project/widgets/CustomGoogleMapWidget.dart';

class DriverMapScreen extends StatefulWidget {
  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;
  bool isJobStarted = false;

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

      final String requestTag =
          (requestData['id'] ?? requestData['data']?['id'] ?? "0").toString();

      return GetBuilder<DriverTowingController>(
        init: DriverTowingController(requestData: requestData),
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
                  customerLocation: s.customerLocation != null
                      ? LatLng(
                          s.customerLocation!.latitude,
                          s.customerLocation!.longitude,
                        )
                      : null,
                  routePoints: s.routePoints,
                  isJobStarted: isJobStarted,
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
                  bottom: 110,
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

  Widget _buildStatusStepper(DriverTowingController s) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(s.statusSequence.length, (index) {
          bool isCurrent = s.currentStatusIndex == index;
          bool isPast = s.currentStatusIndex > index;
          return Icon(
            s.statusSequence[index]['icon'],
            color: isCurrent
                ? const Color(0xFFE55757)
                : (isPast ? Colors.green : Colors.grey[300]),
            size: 28,
          );
        }),
      ),
    );
  }

  Widget _buildFancyInfoCard(DriverTowingController s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.social_distance,
                "${s.distanceToCustomer ?? '--'} كم",
                "المسافة",
              ),
              Container(height: 40, width: 1, color: Colors.grey[200]),
              _buildStatItem(
                Icons.timelapse,
                "${s.estimatedTime ?? '--'} د",
                "الوقت المتوقع",
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButton(s),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE55757), size: 22),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () async {
        if (!isJobStarted) {
          bool success = await s.startTowing();
          if (success) {
            setState(() => isJobStarted = true);
            s.currentStatusIndex = 0;
            s.update();
            Get.snackbar("نجاح", "بدأت المهمة");
          }
        } else if (!isLastStep) {
          String nextStatusKey =
              s.statusSequence[s.currentStatusIndex + 1]['key'];
          bool apiSuccess = await s.updateTowStatusAPI(nextStatusKey);

          if (apiSuccess) {
            s.currentStatusIndex++;
            s.update();
          } else {
            Get.snackbar("تنبيه", "فشل تحديث الحالة");
          }
        } else {
          s.completeTowingViaSocket();
        }
      },
      child: Text(
        !isJobStarted
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
