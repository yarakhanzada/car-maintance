import 'dart:convert';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:senior_project/services/api_config.dart';

class MapHelper {
  static double calculateAirDistance(LatLng pos1, LatLng pos2) {
    const double R = 6371000;
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
    return R * c;
  }

  static Future<Map<String, String>?> getRouteData(
    LatLng start,
    LatLng end,
  ) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=false';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          double dist = data['routes'][0]['distance'] / 1000; // تحويل لكم
          double dur = data['routes'][0]['duration'] / 60; // تحويل لدقائق
          return {
            'distance': dist.toStringAsFixed(1),
            'duration': dur.toStringAsFixed(0),
          };
        }
      }
    } catch (e) {
      print("OSRM Error: $e");
    }
    return null;
  }

  static Future<List<LatLng>> getPolylinePoints(
    LatLng start,
    LatLng end,
  ) async {
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=${ApiConfig.openRouteApiKey}&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coords = data['features'][0]['geometry']['coordinates'];
        return coords
            .map((c) => LatLng(c[1] as double, c[0] as double))
            .toList();
      }
    } catch (e) {
      print("ORS Polyline Error: $e");
    }
    return [];
  }
}
