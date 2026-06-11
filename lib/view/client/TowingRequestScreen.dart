import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senior_project/controller/client%20controller/TowingTrackingController.dart';
import 'dart:math' as math;

class RequestTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  const RequestTrackingScreen({super.key, required this.requestData});

  @override
  State<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends State<RequestTrackingScreen> {
  GoogleMapController? _googleMapController;
  late TowingTrackingController _controller;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // الخريطة
            const GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(33.5138, 36.2765), zoom: 14),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
            // كارد البيانات السفلي والتفاصيل المتجاوبة
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(width * 0.05),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("تفاصيل تتبع السطحة مباشرة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("حالة السائق الحالي:"),
                        Text("قادم إليك الآن", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        minimumSize: Size(width, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("العودة للخلف"),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}