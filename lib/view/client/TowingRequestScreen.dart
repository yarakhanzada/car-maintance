import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:math' as math;

import 'package:senior_project/controller/client%20controller/TowingTrackingController.dart';
import 'package:senior_project/services/token_service.dart';

class RequestTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  const RequestTrackingScreen({super.key, required this.requestData});

  @override
  State<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends State<RequestTrackingScreen> {
  GoogleMapController? _googleMapController;
  late TowingTrackingController _controller;

  late String _estimatedFee;

  @override
  void initState() {
    super.initState();
    _checkRequestValidity();

    _parseInitialData();

    _controller = TowingTrackingController(
      requestData: widget.requestData,
      onUpdate: () {
        if (mounted) {
          setState(() {
            if (_controller.isAccepted &&
                _controller.towTruckLocation != null) {
              _googleMapController?.animateCamera(
                CameraUpdate.newLatLng(_controller.towTruckLocation!),
              );
            }
          });
        }
      },
    );

    _controller.start().then((_) {
      _googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_controller.routeService.userLocation, 15.0),
      );

      if (mounted) setState(() {});
    });
  }

  Future<void> _checkRequestValidity() async {
    final reqData = widget.requestData.containsKey('data')
        ? widget.requestData['data']
        : widget.requestData;

    final requestId = reqData['id'];

    if (requestId == null || requestId == 0) {
      await TokenService.clearActiveRequestForCurrentUser();
      if (mounted) {
        Get.back();
      }
      return;
    }
  }

  void _parseInitialData() {
    final data = widget.requestData;
    _estimatedFee =
        "${(data['estimated_cost'] as num?)?.toStringAsFixed(0) ?? "0"} ل.س";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGoogleMap(),

          Positioned(top: 55, right: 20, child: _backButton()),

          Align(
            alignment: Alignment.bottomCenter,
            child: () {
              final reqData = widget.requestData.containsKey('data')
                  ? widget.requestData['data']
                  : widget.requestData;

              final status = (reqData['status'] ?? '').toString().toLowerCase();

              bool hasDriver =
                  _controller.isAccepted ||
                  status == 'accepted' ||
                  reqData['assigned_tow_truck_id'] != null ||
                  reqData['tow_truck_id'] != null ||
                  reqData['driver_id'] != null;

              return hasDriver
                  ? _buildDriverArrivalSheet()
                  : _buildSearchingSheet();
            }(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _controller.routeService.userLocation,
        zoom: 15,
      ),
      onMapCreated: (controller) => _googleMapController = controller,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      polylines: {
        if (_controller.isAccepted &&
            _controller.routeService.routePoints.isNotEmpty)
          Polyline(
            polylineId: const PolylineId("route"),
            points: _controller.routeService.routePoints,
            color: const Color(0xFFE55757),
            width: 5,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
      },
      markers: {
        Marker(
          markerId: const MarkerId("user_loc"),
          position: _controller.userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: "موقعي الحالي"),
        ),
        if (_controller.isAccepted && _controller.towTruckLocation != null)
          Marker(
            markerId: const MarkerId("driver_loc"),
            position: _controller.towTruckLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            rotation: 0,
            infoWindow: const InfoWindow(title: "سيارة السحب"),
          ),
      },
    );
  }

  Widget _buildSearchingSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: _sheetDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(),
          LoadingAnimationWidget.progressiveDots(
            color: const Color(0xFFE55757),
            size: 45,
          ),
          const SizedBox(height: 10),
          const Text(
            "جاري البحث عن أقرب سائق سحب...",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 15),
          _infoRow(
            _controller.routeService.liveDuration,
            _controller.routeService.liveDistance,
            _estimatedFee,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverArrivalSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: _sheetDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(),
          //   _buildStatusBadge(),
          const SizedBox(height: 15),
          // Row(
          //   children: [
          //     CircleAvatar(
          //       radius: 26,
          //       backgroundColor: Colors.grey[200],
          //       child: const Icon(Icons.person, size: 30, color: Colors.grey),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             _controller.driverData?['driver_name'] ?? 'سائق السحب',
          //             style: const TextStyle(
          //               fontWeight: FontWeight.bold,
          //               fontSize: 16,
          //             ),
          //           ),
          //           Text(
          //             _controller.driverData?['truck_model'] ?? 'شاحنة  ',
          //             style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          //           ),
          //         ],
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     _contactButton(Icons.phone, Colors.green, () {}),
          //   ],
          // ),
          // const Divider(height: 30),
          _infoRow(
            _controller.routeService.liveDuration,
            _controller.routeService.liveDistance,
            _estimatedFee,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    bool isVeryClose =
        _controller.routeService.liveDistance.contains("0.") ||
        _controller.routeService.liveDistance == "0 كم";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isVeryClose
            ? Colors.orange.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isVeryClose ? "السائق وصل تقريباً!" : "السائق يتجه إليك الآن",
        style: TextStyle(
          color: isVeryClose ? Colors.orange[800] : Colors.green[800],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _infoRow(String time, String dist, String cost) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _infoTile("الوقت المتوقع", time, const Color(0xFFE55757)),
        _infoTile("المسافة", dist, Colors.blue),
        _infoTile("التكلفة", cost, Colors.green),
      ],
    );
  }

  Widget _infoTile(String title, String value, Color color) => Column(
    children: [
      Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 15,
        ),
      ),
    ],
  );

  Widget _contactButton(IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      );

  BoxDecoration _sheetDecoration() => const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 5),
    ],
  );

  Widget _dragHandle() => Container(
    margin: const EdgeInsets.only(bottom: 10),
    width: 45,
    height: 5,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(10),
    ),
  );

  Widget _backButton() => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }
}
