import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:senior_project/controller/auth_controller.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/utils/map_helper.dart';
import 'package:senior_project/view/client/ClientBottombar.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../services/token_service.dart';

class TowingTrackingController {
  final Map<String, dynamic> requestData;
  IO.Socket? socket;

  bool isAccepted = false;
  Map<String, dynamic>? driverData;
  LatLng? towTruckLocation;
  List<LatLng> routePoints = [];
  LatLng userLocation = const LatLng(33.5138, 36.2765);

  late String liveDistance;
  late String liveDuration;

  StreamSubscription<Position>? positionStream;
  Function? onUpdate;

  late String customerId;
  late String driverId;

  TowingTrackingController({required this.requestData, this.onUpdate}) {
    _initializeEstimatedStats();
    final data = requestData.containsKey('data')
        ? requestData['data']
        : requestData;
    if (data['status'] == 'accepted' || data['driver_id'] != null) {
      isAccepted = true;
      driverData = {
        'driver_name': data['driver_name'] ?? 'سائق السحب',
        'truck_model': data['truck_model'] ?? 'شاحنة سحب',
      };
      if (data['driver_latitude'] != null && data['driver_longitude'] != null) {
        towTruckLocation = LatLng(
          (data['driver_latitude'] as num).toDouble(),
          (data['driver_longitude'] as num).toDouble(),
        );
        updateRouteData(towTruckLocation!);
      }
    }
  }

  void _initializeEstimatedStats() {
    final data = requestData.containsKey('data')
        ? requestData['data']
        : requestData;
    final double initialDist = (data['distance_km'] as num?)?.toDouble() ?? 0.0;
    final int initialTime =
        (data['estimated_time_minutes'] as num?)?.toInt() ?? 0;

    liveDistance = initialDist > 0
        ? "${initialDist.toStringAsFixed(1)} كم"
        : "-- كم";
    liveDuration = initialTime > 0 ? "$initialTime دقيقة" : "-- دقيقة";
  }

  Future<void> initLocationServices() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLocation = LatLng(position.latitude, position.longitude);

      positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((Position pos) {
            userLocation = LatLng(pos.latitude, pos.longitude);

            if (socket != null && socket!.connected) {
              socket!.emit('update_customer_location', {
                'customer_id': customerId,
                'driver_id': driverId,
                'latitude': userLocation.latitude,
                'longitude': userLocation.longitude,
              });
            }
            if (onUpdate != null) onUpdate!();
          });
    } catch (e) {
      print("Error in initLocationServices: $e");
    }
    if (onUpdate != null) onUpdate!();
  }

  Future<void> initSocket() async {
    try {
      final authController = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : Get.put(AuthController());

      await authController.refreshToken();

      final token = await TokenService.getToken() ?? '';
      if (token.isEmpty) {
        print("⚠️ Token is empty. Cannot connect.");
        return;
      }

      final data = requestData.containsKey('data')
          ? requestData['data']
          : requestData;
      final serviceRequest = data['service_request'];

      customerId =
          (serviceRequest?['user_id'] ??
                  data['user_id'] ??
                  requestData['user_id'] ??
                  "0")
              .toString();

      driverId =
          (serviceRequest?['tow_truck_id'] ??
                  data['assigned_tow_truck_id'] ??
                  requestData['driver_id'] ??
                  "0")
              .toString();

      if (socket != null) {
        socket!.disconnect();
        socket!.dispose();
      }

      socket = IO.io(
        ApiConfig.socketServerUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      _setupSocketListeners();
      socket!.connect();
    } catch (e) {
      print("❌ Error in initSocket: $e");
    }
  }

  void _setupSocketListeners() {
    if (socket == null) return;

    socket!.onConnect((_) {
      print('🚀 Connected to Socket server');
      socket!.emit('subscribe_to_driver', {
        'customer_id': customerId,
        'driver_id': driverId,
      });
    });

    socket!.on('driver_location_update', (data) async {
      isAccepted = true;

      driverData = {
        'driver_name': data['driver_name'] ?? 'سائق السحب',
        'truck_model': data['truck_model'] ?? 'Tow Truck',
      };

      towTruckLocation = LatLng(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      );

      if (towTruckLocation != null) {
        await updateRouteData(towTruckLocation!);
      }

      if (onUpdate != null) onUpdate!();
    });

    socket!.on('tracking_ended', (data) {
      print("🚨 [SOCKET] Tracking Ended Event Received Successfully!");

      // 1. حذف الطلب  من الذاكرة المحلية (GetStorage)
      final box = GetStorage();
      box.remove('active_towing_request');

      // 2. تصفير المتغيرات المحلية
      isAccepted = false;
      towTruckLocation = null;
      routePoints.clear();
      if (onUpdate != null) onUpdate!();

      // 3.  \ إعادة لشاشة الهوم الرئيسية
      Get.offAll(() => ClientBottombar());

      // 4.  رسالة تنبيه  بنجاح وإتمام الرحلة
      Get.snackbar(
        "Success",
        "تم إنهاء الرحلة  ",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    });
  }

  Future<void> updateRouteData(LatLng truckPos) async {
    try {
      final points = await MapHelper.getPolylinePoints(truckPos, userLocation);
      if (points.isNotEmpty) {
        routePoints = points;
      }

      final routeData = await MapHelper.getRouteData(truckPos, userLocation);
      if (routeData != null) {
        liveDistance = "${routeData['distance']} كم";
        liveDuration = "${routeData['duration']} دقيقة";
      } else {
        double airDist =
            MapHelper.calculateAirDistance(truckPos, userLocation) / 1000;
        liveDistance = "${airDist.toStringAsFixed(1)} كم";
      }

      if (onUpdate != null) onUpdate!();
    } catch (e) {
      print("❌ Error updating route data: $e");
    }
  }

  Future<void> updateTokenAndReconnect() async {
    try {
      final authController = Get.find<AuthController>();
      await authController.refreshToken();
      final newToken = await TokenService.getToken() ?? '';

      if (newToken.isNotEmpty && socket != null) {
        socket!.io.options?['auth'] = {'token': newToken};
        socket!.disconnect().connect();
      }
    } catch (e) {
      print("❌ Error reconnecting: $e");
    }
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    positionStream?.cancel();
  }
}
