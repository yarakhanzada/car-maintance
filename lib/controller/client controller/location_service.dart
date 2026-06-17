import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';

import 'route_service.dart';

//GPS +  Update location API
class LocationService {
  final Map<String, dynamic> requestData;
  final RouteService routeService;

  IO.Socket? socket;

  late String customerId;
  late String driverId;

  DateTime? lastApiUpdate;

  StreamSubscription<Position>? positionStream;

  Function? onUpdate;

  LocationService({
    required this.requestData,
    required this.routeService,
    this.onUpdate,
  });

  Future<void> initLocationServices() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      routeService.updateUserLocation(
        LatLng(position.latitude, position.longitude),
      );

      positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((Position pos) {
            routeService.updateUserLocation(
              LatLng(pos.latitude, pos.longitude),
            );

            if (socket != null && socket!.connected) {
              socket!.emit('update_customer_location', {
                'customer_id': customerId,
                'driver_id': driverId,
                'latitude': pos.latitude,
                'longitude': pos.longitude,
              });
            }

            if (lastApiUpdate == null ||
                DateTime.now().difference(lastApiUpdate!).inSeconds > 30) {
              updateCustomerLocationApi(pos.latitude, pos.longitude);

              lastApiUpdate = DateTime.now();
            }

            if (onUpdate != null) {
              onUpdate!();
            }
          });
    } catch (e) {
      print("Error in initLocationServices: $e");
    }

    if (onUpdate != null) {
      onUpdate!();
    }
  }

  Future<void> updateCustomerLocationApi(double lat, double lng) async {
    final url = "${ApiConfig.baseUrl}/v1/customer/location/update";

    final data = requestData.containsKey('data')
        ? requestData['data']
        : requestData;

    final serviceRequestId = data['towing_request']?['service_request_id'] ?? 0;

    print("DEBUG: Updating location for Service Request ID: $serviceRequestId");

    try {
      final response = await ApiHelper.post(url, {
        "latitude": lat,
        "longitude": lng,
        "service_request_id": serviceRequestId,
      });

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        print("✅ API Update: ${responseBody['message']}");
      } else {
        print(" Failed to update location. Status: ${response.statusCode}");
        print(" Server Response: ${response.body}");
      }
    } catch (e) {
      print(" Error: $e");
    }
  }

  void dispose() {
    positionStream?.cancel();
  }
}
