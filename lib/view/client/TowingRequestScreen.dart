import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senior_project/controller/TowingTrackingController.dart';

class RequestTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  const RequestTrackingScreen({super.key, required this.requestData});

  @override
  State<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends State<RequestTrackingScreen> {
  final MapController _mapController = MapController();
  late TowingTrackingController _controller;

  late String _estimatedDuration;
  late String _estimatedDistance;
  late String _estimatedFee;
  late String _requestId;

  @override
  void initState() {
    super.initState();
    _parseInitialData();

    _controller = TowingTrackingController(
      requestData: widget.requestData,
      onUpdate: () {
        if (mounted) setState(() {});
      },
    );
    _controller.initSocket();
    _controller.initLocationServices().then((_) {
      _mapController.move(_controller.userLocation, 15.0);
    });
  }

  void _parseInitialData() {
    final data = widget.requestData;
    _requestId = (data['service_request']?['id'] ?? "0").toString();
    _estimatedDistance =
        "${(data['distance_km'] as num?)?.toStringAsFixed(1) ?? "0"} km";
    _estimatedDuration =
        "${(data['estimated_time_minutes'] as num?)?.toStringAsFixed(0) ?? "0"} mins";
    _estimatedFee =
        "${(data['estimated_cost'] as num?)?.toStringAsFixed(0) ?? "0"} SYP";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(_controller.isAccepted),

          Positioned(top: 50, left: 20, child: _backButton()),
          Align(
            alignment: Alignment.bottomCenter,
            child: _controller.isAccepted
                ? _buildDriverArrivalSheet(
                    _controller.driverData ??
                        {
                          'driver_name': 'سائق السحب',
                          'truck_model': 'Tow Truck',
                        },
                  )
                : _buildSearchingSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(bool isAccepted) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _controller.userLocation,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.senior_project',
        ),
        if (isAccepted && _controller.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _controller.routePoints,
                color: const Color(0xFFE55757),
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: _controller.userLocation,
              child: const Icon(
                Icons.person_pin_circle,
                color: Colors.blue,
                size: 40,
              ),
            ),
            if (isAccepted && _controller.towTruckLocation != null)
              Marker(
                point: _controller.towTruckLocation!,
                child: _buildTowTruckMarker(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchingSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _sheetDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.progressiveDots(
            color: const Color(0xFFE55757),
            size: 50,
          ),
          const Text(
            "Searching for nearby tow trucks...",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile("Est. Time", _estimatedDuration, Colors.black),
              _infoTile("Est. Distance", _estimatedDistance, Colors.green),
              _infoTile("Est. Fee", _estimatedFee, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverArrivalSheet(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _sheetDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Tow Truck is on the way!",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE55757),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              data['driver_name'] ?? "Samer Al-Ahmad",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(data['truck_model'] ?? "White GMC Tow Truck"),
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _sheetDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ],
  );

  Widget _infoTile(String t, String v, Color c) => Column(
    children: [
      Text(t, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text(
        v,
        style: TextStyle(fontWeight: FontWeight.bold, color: c, fontSize: 16),
      ),
    ],
  );

  Widget _buildTowTruckMarker() => Container(
    decoration: const BoxDecoration(
      color: Color(0xFFE55757),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.local_shipping, color: Colors.white, size: 25),
  );

  Widget _backButton() => IconButton(
    onPressed: () => Navigator.pop(context),
    icon: const CircleAvatar(
      backgroundColor: Colors.white,
      child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
