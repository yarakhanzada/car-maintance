import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:senior_project/utils/map_helper.dart';

//location + route + distance
class RouteService {
  final Map<String, dynamic> requestData;

  LatLng userLocation = const LatLng(33.5138, 36.2765);

  List<LatLng> routePoints = [];

  late String liveDistance;
  late String liveDuration;

  Function? onUpdate;

  RouteService({required this.requestData, this.onUpdate}) {
    initializeEstimatedStats();
  }

  void initializeEstimatedStats() {
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

      if (onUpdate != null) {
        onUpdate!();
      }
    } catch (e) {
      print(" Error updating route data: $e");
    }
  }

  void updateUserLocation(LatLng location) {
    userLocation = location;
  }
}
