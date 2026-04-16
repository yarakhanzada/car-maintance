class VehicleModel {
  final int id;
  final String brand;
  final String model;
  final String year;
  final String chassisNumber;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.chassisNumber,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'].toString(),
      chassisNumber: json['chassis_number'] ?? '',
    );
  }
}
