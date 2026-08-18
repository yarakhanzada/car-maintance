import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
              //    updateCustomerLocationApi(pos.latitude, pos.longitude);

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

  void dispose() {
    positionStream?.cancel();
  }
}
