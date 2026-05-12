import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:senior_project/controller/DriverNavigationController.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/token_service.dart';

class DriverTowingController extends GetxController {
  final Map<String, dynamic> requestData;
  IO.Socket? socket;

  LatLng driverLocation = const LatLng(33.5138, 36.2765);
  LatLng? customerLocation;
  List<LatLng> routePoints = [];

  StreamSubscription<Position>? positionStream;

  late String customerId;
  late String driverId;
  late String requestId;
  bool isConnected = false;
  String? distanceToCustomer;
  String? estimatedTime;

  int currentStatusIndex = 0;
  final List<Map<String, dynamic>> statusSequence = [
    {
      "title": "بدء التوجه",
      "key": "tow_on_the_way",
      "icon": Icons.directions_car,
    },
    {
      "title": "وصلت للزبون",
      "key": "tow_arrived_at_customer",
      "icon": Icons.location_on,
    },
    {
      "title": "جاري السحب",
      "key": "tow_in_progress",
      "icon": Icons.local_shipping,
    },
    {
      "title": "العودة للورشة",
      "key": "tow_returning_to_workshop",
      "icon": Icons.home_repair_service,
    },
  ];
  DriverTowingController({required this.requestData});

  @override
  void onInit() {
    super.onInit();
    _extractIds();
    initLocationServices();
    initSocket();
  }

  double _calculateAirDistance(LatLng pos1, LatLng pos2) {
    const double R = 6371000; // نصف قطر الأرض بالأمتار

    double lat1 = pos1.latitude * math.pi / 180;
    double lat2 = pos2.latitude * math.pi / 180;
    double dLat = (pos2.latitude - pos1.latitude) * math.pi / 180;
    double dLng = (pos2.longitude - pos1.longitude) * math.pi / 180;

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c; // المسافة بالأمتار
  }

  void _extractIds() {
    final data = requestData.containsKey('data')
        ? requestData['data']
        : requestData;

    requestId = (data['id'] ?? data['towing_request']?['id'] ?? "0").toString();
    customerId =
        (data['user_id'] ??
                data['towing_request']?['service_request']?['user_id'] ??
                "0")
            .toString();
    driverId = (data['towing_request']?['tow_truck_id'] ?? "0").toString();

    if (data['towing_request']?['location'] != null) {
      customerLocation = LatLng(
        (data['towing_request']['location']['latitude'] as num).toDouble(),
        (data['towing_request']['location']['longitude'] as num).toDouble(),
      );
      print(
        "📍 Customer Location Loaded: ${customerLocation!.latitude}, ${customerLocation!.longitude}",
      );
    }

    // 3. ضبط موقع السائق  على موقع الشركة (Workshop)
    driverLocation = const LatLng(33.5138, 36.2765);

    update();
  }

  Future<void> initLocationServices() async {
    if (socket != null && socket!.connected) {
      socket!.emit('towtrucklocationupdate', {
        'customer_id': customerId,
        'driver_id': driverId,
        'latitude': driverLocation.latitude,
        'longitude': driverLocation.longitude,
      });
    }

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position pos) {
          driverLocation = LatLng(pos.latitude, pos.longitude);

          if (socket != null && socket!.connected) {
            socket!.emit('towtrucklocationupdate', {
              'customer_id': customerId,
              'driver_id': driverId,
              'latitude': driverLocation.latitude,
              'longitude': driverLocation.longitude,
            });
          }

          _calculateRoute();
          calculateRouteData();
          update();
        });
  }

  Future<void> initSocket() async {
    final token = await TokenService.getToken() ?? '';
    socket = IO.io(
      ApiConfig.socketServerUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': 'Bearer $token'})
          .build(),
    );

    _setupSocketListeners();
    socket!.connect();
  }

  void _setupSocketListeners() {
    socket!.onConnect((_) {
      isConnected = true;
      socket!.emit('subscribe_to_customer', {
        'customer_id': customerId,
        'driver_id': driverId,
      });
      update();
    });

    socket!.on('customer_location_update', (data) {
      customerLocation = LatLng(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      );
      calculateRouteData();
      _calculateRoute();
      update();
    });

    socket!.on('tracking_ended', (data) async {
      await completeTowingAPI();

      Get.find<DriverNavigationController>().activeOrderData.value = null;
      Get.snackbar("نجاح", "تم إنهاء المهمة وإغلاق التتبع");
      update();
    });

    socket!.on('tow_complete_rejected', (data) {
      // جلب المسافة الحالية والمسموحة من البيانات القادمة من السيرفر
      int currentDist = data['current_distance_meters'] ?? 0;
      int maxDist = data['max_allowed_meters'] ?? 200;
      String serverMessage = data['message'] ?? "أنت بعيد جداً عن موقع الزبون";

      Get.defaultDialog(
        title: "تعذر إنهاء المهمة",
        titleStyle: const TextStyle(
          color: Color(0xFFE55757),
          fontWeight: FontWeight.bold,
        ),
        content: Column(
          children: [
            const Icon(Icons.location_off, size: 50, color: Color(0xFFE55757)),
            const SizedBox(height: 15),
            Text(
              serverMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(),
            // عرض المسافات بشكل توضيحي للسائق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDistanceInfo("المسافة الحالية", "$currentDist م"),
                _buildDistanceInfo("النطاق المسموح", "$maxDist م"),
              ],
            ),
          ],
        ),
        textConfirm: "حسناً",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFE55757),
        onConfirm: () => Get.back(),
      );
    });

    socket!.onDisconnect((_) => isConnected = false);
  }

  Widget _buildDistanceInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  // --- خدمات  والمسار ---

  Future<void> _calculateRoute() async {
    if (customerLocation == null) return;
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=${ApiConfig.openRouteApiKey}&start=${driverLocation.longitude},${driverLocation.latitude}&end=${customerLocation!.longitude},${customerLocation!.latitude}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coords = data['features'][0]['geometry']['coordinates'];
        routePoints = coords
            .map((c) => LatLng(c[1] as double, c[0] as double))
            .toList();
        update();
      }
    } catch (e) {
      print("Error route: $e");
    }
  }

  Future<void> calculateRouteData() async {
    if (customerLocation == null) return;
    final url =
        'https://router.project-osrm.org/route/v1/driving/${driverLocation.longitude},${driverLocation.latitude};${customerLocation!.longitude},${customerLocation!.latitude}?overview=false';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          distanceToCustomer = (data['routes'][0]['distance'] / 1000)
              .toStringAsFixed(1);
          estimatedTime = (data['routes'][0]['duration'] / 60).toStringAsFixed(
            0,
          );
          update();
        }
      }
    } catch (e) {}
  }

  // --- APIS ---

  Future<bool> startTowing() async {
    final id =
        (requestData['towing_request']?['id'] ?? requestData['id'] ?? requestId)
            .toString();
    final url = "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/start";

    try {
      final response = await ApiHelper.post(url, {
        "latitude": driverLocation.latitude,
        "longitude": driverLocation.longitude,
      });

      print(" [RESPONSE StartTowing] Status: ${response.statusCode}");
      print(" [BODY StartTowing]: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      print(" [EXCEPTION START]: $e");
    }
    return false;
  }

  Future<bool> updateTowStatusAPI(String status) async {
    final id =
        (requestData['towing_request']?['id'] ?? requestData['id'] ?? requestId)
            .toString();
    final url = "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/status";
    print(" Sending to API -> ID: $id, Status: $status");

    print(" [ UPDATE STATUS] URL: $url | New Status: $status");

    try {
      final response = await ApiHelper.post(url, {
        "status": status,
        "latitude": driverLocation.latitude,
        "longitude": driverLocation.longitude,
      });

      print(" [RESPONSE UpdateTowStatus] Status: ${response.statusCode}");
      print(" [BODY UpdateTowStatus]: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(" [EXCEPTION STATUS]: $e");
    }
    return false;
  }

  Future<bool> completeTowingAPI() async {
    final id =
        (requestData['towing_request']?['id'] ?? requestData['id'] ?? requestId)
            .toString();
    final url = "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/complete";

    try {
      final response = await ApiHelper.post(url, {
        "latitude": driverLocation.latitude,
        "longitude": driverLocation.longitude,
      });

      print(" [RESPONSE CompleteTowingAPI] Status: ${response.statusCode}");
      print(" [BODY CompleteTowingAPI]: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(" [EXCEPTION COMPLETE]: $e");
    }
    return false;
  }

  // ---  الإنهاء عبر السوكيت ---
  void completeTowingViaSocket() {
    if (socket != null && socket!.connected) {
      socket!.emit('tow_completed', {
        'customer_id': customerId,
        'driver_id': driverId,
      });
    }
  }

  @override
  void onClose() {
    positionStream?.cancel();
    socket?.dispose();
    super.onClose();
  }
}
