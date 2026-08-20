import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:senior_project/controller/client%20controller/TowingTrackingController.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/token_service.dart';
import 'package:senior_project/utils/map_helper.dart';

class RequestTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  const RequestTrackingScreen({super.key, required this.requestData});

  @override
  State<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends State<RequestTrackingScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _googleMapController;
  late TowingTrackingController _controller;
  late AnimationController _truckAnimController;

  late String _estimatedFee;
  bool _hasCenteredOnWorkshop = false;
  BitmapDescriptor? _workshopIcon;

  LatLng? _truckAnimFrom;
  LatLng? _truckAnimTo;
  LatLng? _displayedTruckLocation;

  @override
  void initState() {
    super.initState();
    //TokenService.clearActiveRequestForCurrentUser();
    print("DEBUG: Raw requestData received: ${widget.requestData}");

    _truckAnimController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000),
        )..addListener(() {
          if (_truckAnimFrom == null || _truckAnimTo == null) return;
          final t = Curves.easeInOut.transform(_truckAnimController.value);
          setState(() {
            _displayedTruckLocation = LatLng(
              _truckAnimFrom!.latitude +
                  (_truckAnimTo!.latitude - _truckAnimFrom!.latitude) * t,
              _truckAnimFrom!.longitude +
                  (_truckAnimTo!.longitude - _truckAnimFrom!.longitude) * t,
            );
          });
        });

    _checkRequestValidity();

    _parseInitialData();

    MapHelper.getWorkshopIcon().then((icon) {
      if (mounted) setState(() => _workshopIcon = icon);
    });

    _controller = TowingTrackingController(
      requestData: widget.requestData,
      onUpdate: () {
        if (mounted) {
          setState(() {
            if (_controller.isAccepted &&
                _controller.towTruckLocation != null) {
              _animateTruckTo(_controller.towTruckLocation!);
              if (_controller.routeService.isReturningToWorkshop) {
                _centerOnWorkshopOnce(_controller.towTruckLocation!);
              } else {
                _googleMapController?.animateCamera(
                  CameraUpdate.newLatLng(_controller.towTruckLocation!),
                );
              }
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

  void _animateTruckTo(LatLng newPosition) {
    if (_truckAnimTo != null &&
        _truckAnimTo!.latitude == newPosition.latitude &&
        _truckAnimTo!.longitude == newPosition.longitude) {
      return;
    }
    _truckAnimFrom = _displayedTruckLocation ?? newPosition;
    _truckAnimTo = newPosition;
    _truckAnimController
      ..reset()
      ..forward();
  }

  Future<void> _checkRequestValidity() async {
    final body = widget.requestData.containsKey('data')
        ? widget.requestData['data']
        : widget.requestData;

    final requestId = body['id'] ?? body['service_request']?['id'];

    print("DEBUG: Final Request ID found: $requestId");

    if (requestId == null) {
      print("DEBUG: No ID found, closing screen.");
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

  // Fits both the truck and the workshop into view (centered) the moment
  // the truck starts heading there, instead of leaving the workshop flag
  // off-screen until the user manually pans the map.
  void _centerOnWorkshopOnce(LatLng truckLocation) {
    if (_hasCenteredOnWorkshop || _googleMapController == null) return;
    _hasCenteredOnWorkshop = true;

    final workshop = ApiConfig.workshopLocation;
    final bounds = LatLngBounds(
      southwest: LatLng(
        truckLocation.latitude < workshop.latitude
            ? truckLocation.latitude
            : workshop.latitude,
        truckLocation.longitude < workshop.longitude
            ? truckLocation.longitude
            : workshop.longitude,
      ),
      northeast: LatLng(
        truckLocation.latitude > workshop.latitude
            ? truckLocation.latitude
            : workshop.latitude,
        truckLocation.longitude > workshop.longitude
            ? truckLocation.longitude
            : workshop.longitude,
      ),
    );

    _googleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
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
            position: _displayedTruckLocation ?? _controller.towTruckLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            rotation: 0,
            infoWindow: const InfoWindow(title: "سيارة السحب"),
          ),
        if (_controller.routeService.isReturningToWorkshop)
          Marker(
            markerId: const MarkerId("workshop_loc"),
            position: ApiConfig.workshopLocation,
            icon:
                _workshopIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet,
                ),
            infoWindow: const InfoWindow(title: "الورشة"),
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
          const SizedBox(height: 15),

          if (_controller.routeService.isReturningToWorkshop) ...[
            Text(
              "السائق في طريق العودة للورشة مع مركبتك",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 10),
          ],
          _infoRow(
            _controller.routeService.liveDuration,
            _controller.routeService.liveDistance,
            _estimatedFee,
          ),
        ],
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
    _truckAnimController.dispose();
    _controller.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }
}
