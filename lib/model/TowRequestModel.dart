class TowRequest {
  final int towingRequestId;
  final String customerName;
  final String customerPhone;
  final String carBrand;
  final String carModel;
  final String carYear;
  final String chassisNumber;
  final String problemType;   
  final double distanceKm;
  final String status;
  final double amount;

  TowRequest({
    required this.towingRequestId,
    required this.customerName,
    required this.customerPhone,
    required this.carBrand,
    required this.carModel,
    required this.carYear,
    required this.chassisNumber,
    required this.problemType,
    required this.distanceKm,
    required this.status,
    required this.amount,
  });
factory TowRequest.fromJson(Map<String, dynamic> json) {
  var vehicle = json['vehicle'] as Map<String, dynamic>?;
  var customer = json['customer'] as Map<String, dynamic>?;

  return TowRequest(
    towingRequestId: json['towing_request_id'] ?? 0,
    customerName: (customer?['name'] ?? "N/A").toString(),
    customerPhone: (customer?['phone'] ?? "N/A").toString(),
    carBrand: (vehicle?['brand'] ?? "").toString(),
    carModel: (vehicle?['model'] ?? "").toString(),
    carYear: (vehicle?['year'] ?? "N/A").toString(),
    
    chassisNumber: (vehicle?['chassis_number'] ?? "No Chassis ID").toString(),
    problemType: (json['problem_type'] ?? "General Towing").toString(),
    
    distanceKm: double.tryParse((json['distance_km'] ?? 0).toString()) ?? 0.0,
    status: (json['status'] ?? "N/A").toString(),
    amount: double.tryParse((json['estimated_pay'] ?? 0).toString()) ?? 0.0,
  );
}}