import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/utils/map_helper.dart';

//location + route + distance
class RouteService {
  final Map<String, dynamic> requestData;

  LatLng userLocation = const LatLng(33.5138, 36.2765);

  List<LatLng> routePoints = [];

  // Fixed at request-creation time from the API response and never
  // recalculated afterward — only the polyline (routePoints) keeps updating
  // live as the truck moves.
  late String liveDistance;
  late String liveDuration;

  // Once the driver has picked up the vehicle and is heading back, route
  // toward the workshop instead of the customer.
  bool isReturningToWorkshop = false;

  LatLng get destination =>
      isReturningToWorkshop ? ApiConfig.workshopLocation : userLocation;

  Function? onUpdate;

  // Each GPS ping fires a new routing-API request; responses can arrive out
  // of order (e.g. a stale "heading to customer" request resolving after a
  // newer "heading to workshop" one), which made the route/marker visibly
  // snap between destinations. Only the latest request's result is applied.
  int _requestSeq = 0;

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
    final int seq = ++_requestSeq;
    try {
      final dest = destination;
      final points = await MapHelper.getPolylinePoints(truckPos, dest);
      if (seq != _requestSeq) return; // a newer request already landed

      if (points.isNotEmpty) {
        routePoints = points;
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
