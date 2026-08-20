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
  Timer? _keepAliveTimer;

  // GPS fixes reporting worse than this horizontal accuracy (in meters) are
  // discarded — a noisy fix can otherwise report itself 20-50m off, making
  // the marker visibly snap back and forth even while stationary.
  static const double _maxAcceptableAccuracyMeters = 30;

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

      // Re-sends the last known position on a timer even when the customer
      // hasn't moved, so the server's proximity check (used to gate the
      // driver's "tow_completed") never gets stuck with a stale/one-shot
      // reading from before the socket was even connected.
      _keepAliveTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        _emitLocation(routeService.userLocation);
      });

      positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((Position pos) {
            if (pos.accuracy > _maxAcceptableAccuracyMeters) return;
            routeService.updateUserLocation(
              LatLng(pos.latitude, pos.longitude),
            );

            _emitLocation(LatLng(pos.latitude, pos.longitude));

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

  void _emitLocation(LatLng position) {
    if (socket != null && socket!.connected) {
      socket!.emit('update_customer_location', {
        'customer_id': customerId,
        'driver_id': driverId,
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    }
  }

  // Called once the socket actually connects, so the server has a fresh
  // customer position right away instead of waiting on the next >5m move
  // (which may never come if the customer is standing still).
  Future<void> sendCurrentLocationNow() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      routeService.updateUserLocation(latLng);
      _emitLocation(latLng);
      if (onUpdate != null) onUpdate!();
    } catch (e) {
      print("Error in sendCurrentLocationNow: $e");
    }
  }

  void dispose() {
    positionStream?.cancel();
    _keepAliveTimer?.cancel();
  }
}
