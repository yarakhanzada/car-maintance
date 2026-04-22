import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class RequestTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const RequestTrackingScreen({super.key, required this.requestData});

  @override
  State<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends State<RequestTrackingScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  List<LatLng> _routePoints = [];

  late String _duration;
  late String _distance;
  late String _fee;
  late String _requestId;

  LatLng _userLocation = const LatLng(33.5138, 36.2765);
  LatLng _towTruckLocation = const LatLng(33.5045, 36.2575);

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
      _distance =
          "${(data['distance_km'] as num?)?.toStringAsFixed(1) ?? "0"} km";
      _duration =
          "${(data['estimated_time_minutes'] as num?)?.toStringAsFixed(0) ?? "0"} mins";
      _fee =
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
            _getRealRoute(_towTruckLocation, _userLocation);
          }
        });
  }

  Future<void> _getRealRoute(LatLng start, LatLng end) async {
    const String apiKey =
        'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjU0N2NmOWJkYjFmYjQwODM5YmZlNWRjMmQ1ODIzNmQ4IiwiaCI6Im11cm11cjY0In0=';
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['features'][0];
        final List<dynamic> coords = route['geometry']['coordinates'];

        if (mounted) {
          setState(() {
            _routePoints = coords
                .map((c) => LatLng(c[1] as double, c[0] as double))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Routing Error: $e");
    }
  }

  void _zoomToFit() {
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(_userLocation, _towTruckLocation),
        padding: const EdgeInsets.all(80),
      ),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
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
          if (snapshot.hasData && snapshot.data!.exists) {
            var fbData = snapshot.data!.data() as Map<String, dynamic>;
            _towTruckLocation = LatLng(
              (fbData['truck_lat'] as num).toDouble(),
              (fbData['truck_lng'] as num).toDouble(),
            );
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _userLocation,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.senior_project',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints.isEmpty
                            ? [_towTruckLocation, _userLocation]
                            : _routePoints,
                        color: const Color(0xFFE55757),
                        strokeWidth: 4.0,
                        pattern: StrokePattern.dashed(segments: [10, 5]),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _userLocation,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                      Marker(
                        point: _towTruckLocation,
                        width: 45,
                        height: 45,
                        child: _buildTowTruckMarker(),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(top: 50, left: 20, child: _backButton()),
              Positioned(right: 20, bottom: 300, child: _centerButton()),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildInfoSheet(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTowTruckMarker() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE55757),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.local_shipping, color: Colors.white, size: 25),
    );
  }

  Widget _buildInfoSheet() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile("Arrival", _duration, Colors.green),
              _infoTile("Distance", _distance, Colors.black),
              _infoTile("Fee", _fee, Colors.blue),
            ],
          ),
          const Divider(height: 30),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Color(0xFFE55757),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              "Samer Al-Ahmad",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("White GMC Tow Truck"),
            trailing: Icon(Icons.phone, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String t, String v, Color c) => Column(
    children: [
      Text(t, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text(
        v,
        style: TextStyle(fontWeight: FontWeight.bold, color: c, fontSize: 16),
      ),
    ],
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
      child: const Icon(Icons.arrow_back_ios_new, size: 20),
    ),
  );

  Widget _centerButton() => FloatingActionButton(
    mini: true,
    backgroundColor: Colors.white,
    onPressed: _zoomToFit,
    child: const Icon(Icons.center_focus_strong, color: Color(0xFFE55757)),
  );
}
