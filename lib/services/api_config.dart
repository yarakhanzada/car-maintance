import 'package:google_maps_flutter/google_maps_flutter.dart';

class ApiConfig {
  static const String baseUrl = "http://72.61.154.123/api";
  static const String base = "http://72.61.154.123";
  static const String socketServerUrl = 'http://72.61.154.123:3001';
  static const String openRouteApiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjU0N2NmOWJkYjFmYjQwODM5YmZlNWRjMmQ1ODIzNmQ4IiwiaCI6Im11cm11cjY0In0=';

  // Company workshop location — the destination once a tow truck is
  // returning with a vehicle (matches the location set on the backend).
  static const LatLng workshopLocation = LatLng(33.4932432, 36.3181898);
}
