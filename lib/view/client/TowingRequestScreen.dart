import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senior_project/controller/TowingTrackingController.dart';
import 'dart:math' as math;

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
        if (mounted) {
          setState(() {
            if (_controller.isAccepted &&
                _controller.towTruckLocation != null) {
              _mapController.move(_controller.towTruckLocation!, 15.0);
            }
          });
        }
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
        "${(data['distance_km'] as num?)?.toStringAsFixed(1) ?? "0"} كم";
    _estimatedDuration =
        "${(data['estimated_time_minutes'] as num?)?.toStringAsFixed(0) ?? "0"} دقيقة";
    _estimatedFee =
        "${(data['estimated_cost'] as num?)?.toStringAsFixed(0) ?? "0"} ل.س";
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const R = 6371000;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  bool get _isDriverArrived {
    if (_controller.towTruckLocation == null) return false;
    final distance = _calculateDistance(
      _controller.userLocation.latitude,
      _controller.userLocation.longitude,
      _controller.towTruckLocation!.latitude,
      _controller.towTruckLocation!.longitude,
    );
    return distance <= 200.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(_controller.isAccepted),

          Positioned(top: 55, left: 20, child: _backButton()),

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
        if (isAccepted && _controller.towTruckLocation != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _controller.routePoints.isNotEmpty
                    ? _controller.routePoints
                    : [_controller.towTruckLocation!, _controller.userLocation],
                color: const Color(0xFFE55757),
                strokeWidth: 5,
                borderColor: Colors.white,
                borderStrokeWidth: 1.5,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: _controller.userLocation,
              width: 60,
              height: 60,
              child: const PulsatingMarker(),
            ),
            if (isAccepted && _controller.towTruckLocation != null)
              Marker(
                point: _controller.towTruckLocation!,
                width: 45,
                height: 45,
                child: _buildTowTruckMarker(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchingSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: _sheetDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 18),
          LoadingAnimationWidget.progressiveDots(
            color: const Color(0xFFE55757),
            size: 45,
          ),
          const SizedBox(height: 12),
          const Text(
            "جاري البحث عن سيارة سحب قريبة...",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "يرجى الانتظار، سيتم الاتصال بالسائق قريباً.",
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoTile("الوقت", _estimatedDuration, const Color(0xFFE55757)),
                _infoTile("المسافة", _estimatedDistance, Colors.green),
                _infoTile("التكلفة", _estimatedFee, Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverArrivalSheet(Map<String, dynamic> data) {
    final arrived = _isDriverArrived;
    final distanceToPickup = _controller.towTruckLocation != null
        ? _calculateDistance(
            _controller.userLocation.latitude,
            _controller.userLocation.longitude,
            _controller.towTruckLocation!.latitude,
            _controller.towTruckLocation!.longitude,
          )
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: _sheetDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: arrived ? Colors.blue.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  arrived ? Icons.check_circle_outline : Icons.local_shipping,
                  color: arrived ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    arrived
                        ? "وصلت سيارة السحب إلى موقعك"
                        : "سيارة السحب في طريقها إليك (${(distanceToPickup / 1000).toStringAsFixed(2)} كم)",
                    style: TextStyle(
                      color: arrived ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 26),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE55757),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              data['driver_name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              data['truck_model'],
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            trailing: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone, color: Colors.green, size: 22),
              ),
              onPressed: () {
                //  تنفيذ الاتصال
              },
            ),
          ),
          if (arrived) ...[
            const SizedBox(height: 12),
            const Text(
              "السائق الآن عند نقطة الالتقاء، يرجى الاستعداد.",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _sheetDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 18,
        spreadRadius: 3,
        offset: const Offset(0, -3),
      ),
    ],
  );

  Widget _infoTile(String title, String value, Color color) => Column(
    children: [
      Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 3),
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

  Widget _buildTowTruckMarker() => Container(
    padding: const EdgeInsets.all(4),
    decoration: const BoxDecoration(
      color: Color(0xFFE55757),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1),
      ],
    ),
    child: const Icon(Icons.local_shipping, color: Colors.white, size: 18),
  );

  Widget _backButton() => IconButton(
    onPressed: () => Navigator.pop(context),
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: const Icon(
        Icons.arrow_back_ios_new,
        size: 16,
        color: Colors.black,
      ),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    _mapController.dispose();
    super.dispose();
  }
}

class PulsatingMarker extends StatefulWidget {
  const PulsatingMarker({super.key});

  @override
  State<PulsatingMarker> createState() => _PulsatingMarkerState();
}

class _PulsatingMarkerState extends State<PulsatingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 24 + (value * 32),
              height: 24 + (value * 32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.35 * (1 - value)),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
