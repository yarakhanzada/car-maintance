import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMapWidget extends StatelessWidget {
  final LatLng driverLocation;
  final LatLng? customerLocation;
  final List<LatLng> routePoints;
  final bool isJobStarted;
  final Function(GoogleMapController) onMapCreated;

  const CustomGoogleMapWidget({
    super.key,
    required this.driverLocation,
    this.customerLocation,
    this.routePoints = const [],
    this.isJobStarted = false,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: driverLocation, zoom: 14.0),
      onMapCreated: onMapCreated,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,

      markers: {
        // Driver marker
        Marker(
          markerId: const MarkerId("driver"),
          position: driverLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: "موقعي الحالي"),
        ),

        if (customerLocation != null)
          Marker(
            markerId: const MarkerId("customer"),
            position: customerLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: "موقع طلب السحب"),
          ),
      },

      polylines: routePoints.isNotEmpty
          ? {
              Polyline(
                polylineId: const PolylineId("route"),
                points: routePoints,
                color: const Color(0xFFE55757),
                width: 5,
                jointType: JointType.round,
              ),
            }
          : {},
    );
  }
}
