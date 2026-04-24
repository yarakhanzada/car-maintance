import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RequestTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  const RequestTrackingScreen({super.key, required this.requestData});

  @override
  State<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends State<RequestTrackingScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _positionStream;

  late String _estimatedDuration;
  late String _estimatedDistance;
  late String _estimatedFee;
  late String _requestId;

  LatLng _userLocation = const LatLng(33.5138, 36.2765);
  LatLng? _towTruckLocation;

  @override
  void initState() {
    super.initState();
    _parseInitialData();
    _initLocationServices();
  }

  void _parseInitialData() {
    final data = widget.requestData;
    setState(() {
      _requestId = (data['service_request']?['id'] ?? "0").toString();
      _estimatedDistance =
          "${(data['distance_km'] as num?)?.toStringAsFixed(1) ?? "0"} km";
      _estimatedDuration =
          "${(data['estimated_time_minutes'] as num?)?.toStringAsFixed(0) ?? "0"} mins";
      _estimatedFee =
          "${(data['estimated_cost'] as num?)?.toStringAsFixed(0) ?? "0"} SYP";
    });
  }

  Future<void> _initLocationServices() async {
    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_userLocation, 15.0);
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position pos) {
          if (mounted) {
            setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
          }
        });
  }

  Future<void> _updateRoute(LatLng truckPos) async {
    const String apiKey =
        'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjU0N2NmOWJkYjFmYjQwODM5YmZlNWRjMmQ1ODIzNmQ4IiwiaCI6Im11cm11cjY0In0='; // استبدليه بمفتاحك
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${truckPos.longitude},${truckPos.latitude}&end=${_userLocation.longitude},${_userLocation.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coords =
            data['features'][0]['geometry']['coordinates'];
        if (mounted) {
          setState(() {
            _routePoints = coords
                .map((c) => LatLng(c[1] as double, c[0] as double))
                .toList();
          });
        }
      }
    } catch (e) {
      print("Routing Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(_requestId)
            .snapshots(),
        builder: (context, snapshot) {
          bool isAccepted = false;
          Map<String, dynamic>? driverData;

          if (snapshot.hasData && snapshot.data!.exists) {
            var fbData = snapshot.data!.data() as Map<String, dynamic>;

            if (fbData['status'] == 'accepted' || fbData['truck_lat'] != null) {
              isAccepted = true;
              driverData = fbData;
              _towTruckLocation = LatLng(
                (fbData['truck_lat'] as num).toDouble(),
                (fbData['truck_lng'] as num).toDouble(),
              );
              _updateRoute(_towTruckLocation!);
            }
          }

          return Stack(
            children: [
              _buildMap(isAccepted),

              Positioned(top: 50, left: 20, child: _backButton()),
              Align(
                alignment: Alignment.bottomCenter,
                child: isAccepted
                    ? _buildDriverArrivalSheet(driverData!)
                    : _buildSearchingSheet(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(bool isAccepted) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: _userLocation, initialZoom: 15.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.senior_project',
        ),
        if (isAccepted && _routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: const Color(0xFFE55757),
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: _userLocation,
              child: const Icon(
                Icons.person_pin_circle,
                color: Colors.blue,
                size: 40,
              ),
            ),
            if (isAccepted && _towTruckLocation != null)
              Marker(point: _towTruckLocation!, child: _buildTowTruckMarker()),
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
}
