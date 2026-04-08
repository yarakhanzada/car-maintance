import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class RequestTrackingScreen extends StatefulWidget {
  const RequestTrackingScreen({super.key});

  @override
  State<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends State<RequestTrackingScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  List<LatLng> _routePoints = [];

  String _duration = "Calculated...";
  String _distance = "Calculating...";

  LatLng _userLocation = const LatLng(33.5138, 36.2765);
  LatLng _towTruckLocation = const LatLng(33.5045, 36.2575);

  double _truckRotation = 0.0;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _initLocationServices();
  }

  Future<void> _initLocationServices() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

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
            distanceFilter: 5,
          ),
        ).listen((Position pos) {
          if (mounted) {
            setState(() {
              _userLocation = LatLng(pos.latitude, pos.longitude);
            });
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

        double dist = route['properties']['summary']['distance'] / 1000;
        double dur = route['properties']['summary']['duration'] / 60;

        if (mounted) {
          setState(() {
            _routePoints = coords
                .map((c) => LatLng(c[1] as double, c[0] as double))
                .toList();
            _distance = "${dist.toStringAsFixed(1)} km";
            _duration = "${dur.toStringAsFixed(0)} mins";
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
            .doc('request_123')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            LatLng newPos = LatLng(
              (data['truck_lat'] as num).toDouble(),
              (data['truck_lng'] as num).toDouble(),
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
                        width: 60,
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.15),
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Marker(
                        point: _towTruckLocation,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFE55757),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE55757),
                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.local_shipping,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Positioned(
                top: 50,
                left: 20,
                child: _topButton(
                  Icons.arrow_back_ios_new,
                  () => Navigator.pop(context),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 280,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _zoomToFit,
                  child: const Icon(
                    Icons.center_focus_strong,
                    color: Color(0xFFE55757),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildDriverInfoSheet(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _topButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Icon(icon, color: Colors.black, size: 20),
    ),
  );

  Widget _buildDriverInfoSheet() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile("Arrival", _duration, Colors.green),
              _infoTile("Distance", _distance, Colors.black),
              _infoTile("Fee", "60k SYP", Colors.blue),
            ],
          ),
          const Divider(height: 30),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFFE55757),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: const Text(
              "Samer Al-Ahmad",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("White GMC Tow Truck"),
            trailing: _actionCircle(Icons.phone, Colors.green),
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
  Widget _actionCircle(IconData i, Color c) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: c.withOpacity(0.1),
      shape: BoxShape.circle,
    ),
    child: Icon(i, color: c, size: 22),
  );
}
