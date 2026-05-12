class VehicleModel {
  final int id;
  final String brand;
  final String model;
  final String year;
  final String plate_number;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate_number,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'].toString(),
      plate_number: json['plate_number'] ?? '',
    );
  }
}
