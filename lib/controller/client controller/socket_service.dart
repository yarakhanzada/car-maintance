import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:senior_project/controller/auth_controller.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/token_service.dart';
import 'package:senior_project/view/client/ClientBottombar.dart';

import 'route_service.dart';
import 'location_service.dart';

//driver + socke
class SocketService {
  final Map<String, dynamic> requestData;

  final RouteService routeService;
  final LocationService locationService;

  IO.Socket? socket;

  bool isAccepted = false;

  Map<String, dynamic>? driverData;

  LatLng? towTruckLocation;

  late String customerId;
  late String driverId;

  Function? onUpdate;

  SocketService({
    required this.requestData,
    required this.routeService,
    required this.locationService,
    this.onUpdate,
  });

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

      locationService.customerId = customerId;
      locationService.driverId = driverId;

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

      locationService.socket = socket;

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

      // Push a fresh position the moment the socket is actually usable —
      // any GPS reading from before this point (or from the movement-gated
      // stream, if the customer hasn't moved) never reached the server.
      locationService.sendCurrentLocationNow();
    });

    socket!.on('driver_location_update', (data) {
      isAccepted = true;

      driverData = {
        'driver_name': data['driver_name'] ?? 'سائق السحب',
        'truck_model': data['truck_model'] ?? 'Tow Truck',
      };

      towTruckLocation = LatLng(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      );

      final status = data['status']?.toString();
      if (status != null) {
        // The truck is heading to the workshop from "جاري السحب" onward,
        // not just once it hits the final "tow_returning_to_workshop" step.
        routeService.isReturningToWorkshop =
            status == 'tow_in_progress' || status == 'tow_returning_to_workshop';
      }

      // Notify right away so the marker moves instantly; the caller
      // (TowingTrackingController) kicks off the route/ETA refresh in the
      // background so movement never waits on the routing API calls.
      if (onUpdate != null) onUpdate!();
    });

    socket!.on('tracking_ended', (data) async {
      print("🚨 [SOCKET] Tracking Ended Event Received Successfully!");

      final box = GetStorage();
      box.remove('active_towing_request');

      await TokenService.clearActiveRequestForUser(customerId);

      isAccepted = false;
      towTruckLocation = null;
      routeService.routePoints.clear();

      if (onUpdate != null) onUpdate!();

      Get.offAll(() => ClientBottombar());

      Get.snackbar(
        "Success",
        "تم إنهاء الرحلة",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    });
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
    locationService.dispose();
  }
}
