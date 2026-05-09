class TowRequest {
  final int towingRequestId;
  final String status;
  final String problemType;
  final double distanceKm;
  final String customerName;
  final String carBrand;
  final String carModel;
  final String carYear;
  final String chassisNumber;
  final double lat; 
  final double lng;

  TowRequest({
    required this.towingRequestId,
    required this.status,
    required this.problemType,
    required this.distanceKm,
    required this.customerName,
    required this.carBrand,
    required this.carModel,
    required this.carYear,
    required this.chassisNumber,
    required this.lat,
    required this.lng,
  });

  factory TowRequest.fromJson(Map<String, dynamic> json) {
    var customer = json['customer'] as Map<String, dynamic>?;
    var location = customer?['location'] as Map<String, dynamic>?;
    var vehicle = json['vehicle'] as Map<String, dynamic>?;

    return TowRequest(
      towingRequestId: json['towing_request_id'] ?? 0,
      status: json['status'] ?? "",
      problemType: json['problem_type'] ?? "",
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      customerName: customer?['name'] ?? "Unknown",
      carBrand: vehicle?['brand'] ?? "",
      carModel: vehicle?['model'] ?? "",
      carYear: vehicle?['year'] ?? "",
      chassisNumber: vehicle?['chassis_number'] ?? "",
      lat: (location?['latitude'] as num?)?.toDouble() ?? 0.0,
      lng: (location?['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}