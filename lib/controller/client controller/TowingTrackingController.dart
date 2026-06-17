import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'route_service.dart';
import 'location_service.dart';
import 'socket_service.dart';

class TowingTrackingController {
  final Map<String, dynamic> requestData;

  final Function? onUpdate;

  late RouteService routeService;
  late LocationService locationService;
  late SocketService socketService;

  bool isAccepted = false;

  TowingTrackingController({required this.requestData, this.onUpdate}) {
    _initServices();
  }

  void _initServices() {
    routeService = RouteService(requestData: requestData, onUpdate: _notify);

    locationService = LocationService(
      requestData: requestData,
      routeService: routeService,
      onUpdate: _notify,
    );

    socketService = SocketService(
      requestData: requestData,
      routeService: routeService,
      locationService: locationService,
      onUpdate: _onSocketUpdate,
    );
  }

  Future<void> start() async {
    await locationService.initLocationServices();
    await socketService.initSocket();
  }

  void _notify() {
    if (onUpdate != null) onUpdate!();
  }

  void _onSocketUpdate() {
    isAccepted = socketService.isAccepted;

    if (socketService.towTruckLocation != null) {
      routeService.updateRouteData(socketService.towTruckLocation!);
    }

    _notify();
  }

  LatLng get userLocation => routeService.userLocation;

  List<LatLng> get routePoints => routeService.routePoints;

  String get liveDistance => routeService.liveDistance;

  String get liveDuration => routeService.liveDuration;

  Map<String, dynamic>? get driverData => socketService.driverData;

  LatLng? get towTruckLocation => socketService.towTruckLocation;

  Future<void> reconnect() async {
    await socketService.updateTokenAndReconnect();
  }

  void dispose() {
    socketService.dispose();
  }
}
