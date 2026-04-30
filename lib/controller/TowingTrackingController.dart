import 'dart:async';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/token_service.dart';

class TowingTrackingController {
  final Map<String, dynamic> requestData;
  late IO.Socket socket;

  bool isAccepted = false;
  Map<String, dynamic>? driverData;
  LatLng? towTruckLocation;
  List<LatLng> routePoints = [];
  LatLng userLocation = const LatLng(33.5138, 36.2765);

  StreamSubscription<Position>? positionStream;
  Function? onUpdate;

  TowingTrackingController({required this.requestData, this.onUpdate});

  Future<void> initSocket() async {
    final token = await TokenService.getToken() ?? '';
    if (token.isEmpty) {
      print(" Token is empty. Cannot connect.");
      return;
    }

    socket = IO.io(
      ApiConfig.socketServerUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': 'Bearer $token'})
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print(' Connected to Node.js Socket server');
      final customerId = requestData['customer_id'];
      final driverId = requestData['driver_id'];

      socket.emit('subscribe_to_driver', {
        'customer_id': customerId,
        'driver_id': driverId,
      });
    });

    socket.on('token_expired', (data) async {
      print(' Token expired, updating token...');
      await updateTokenAndReconnect();
    });

    socket.on('driver_location_update', (data) {
      isAccepted = true;
      driverData = {'driver_name': 'سائق السحب', 'truck_model': 'Tow Truck'};
      towTruckLocation = LatLng(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      );

      if (towTruckLocation != null) {
        updateRoute(towTruckLocation!);
      }
      if (onUpdate != null) onUpdate!();
    });

    socket.on('tracking_ended', (data) {
      isAccepted = false;
      towTruckLocation = null;
      routePoints.clear();
      if (onUpdate != null) onUpdate!();
    });

    socket.onConnectError((err) => print(' Connect Error: $err'));
    socket.onError((err) => print(' Socket Error: $err'));
  }

  Future<void> updateTokenAndReconnect() async {
    final newToken = await TokenService.getToken() ?? '';
    if (newToken.isNotEmpty) {
      socket.auth = {'token': newToken};

      if (socket.connected) {
        socket.disconnect();
        socket.connect();
      } else {
        socket.connect();
      }
    }
  }

  Future<void> initLocationServices() async {
    Position position = await Geolocator.getCurrentPosition();
    userLocation = LatLng(position.latitude, position.longitude);

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position pos) {
          userLocation = LatLng(pos.latitude, pos.longitude);
          if (socket.connected) {
            final customerId = requestData['customer_id'];
            final driverId = requestData['driver_id'];
            socket.emit('update_customer_location', {
              'customer_id': customerId,
              'driver_id': driverId,
              'latitude': userLocation.latitude,
              'longitude': userLocation.longitude,
            });
          }
          if (onUpdate != null) onUpdate!();
        });
    if (onUpdate != null) onUpdate!();
  }

  Future<void> updateRoute(LatLng truckPos) async {
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=${ApiConfig.openRouteApiKey}&start=${truckPos.longitude},${truckPos.latitude}&end=${userLocation.longitude},${userLocation.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coords =
            data['features'][0]['geometry']['coordinates'];
        routePoints = coords
            .map((c) => LatLng(c[1] as double, c[0] as double))
            .toList();
        if (onUpdate != null) onUpdate!();
      }
    } catch (e) {
      print("Routing Error: $e");
    }
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
    positionStream?.cancel();
  }
}
