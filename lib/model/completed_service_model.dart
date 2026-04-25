class CompletedServiceModel {
  final int id;
  final String problemType;
  final String brand;
  final String model;
  final String finalCost;
  final String completedAt;
  final bool isRated;
  final int? score;
  final bool isComplained;

  CompletedServiceModel({
    required this.id,
    required this.problemType,
    required this.brand,
    required this.model,
    required this.finalCost,
    required this.completedAt,
    required this.isRated,
    this.score,
    required this.isComplained,
  });

  factory CompletedServiceModel.fromJson(Map<String, dynamic> json) {
  
    return CompletedServiceModel(
      id: json['id'],
      problemType: json['problem_type'] ?? "",
      brand: json['vehicle']['brand'] ?? "",
      model: json['vehicle']['model'] ?? "",
      finalCost: json['bill']['total_cost'] ?? "0",
      completedAt: json['completed_request_at'] ?? "",
      isRated: json['is_rated'] ?? false,
      score: json['rating_details'] != null ? json['rating_details']['score'] : null,
      isComplained: json['is_complained'] ?? false,
    );
  }
}