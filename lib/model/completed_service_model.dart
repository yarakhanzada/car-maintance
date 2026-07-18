import 'package:senior_project/services/api_config.dart';

class CompletedServiceModel {
  final int id;
  final String problemType;
  final String status;
  final String brand;
  final String model;
  final String year;
  final String platenumber;
  final String finalCost;
  final String discountAmount;
  final String discountPercentage;
  final String subtotal;
  final String subscription;
  final String completedAt;
  final List<dynamic> billItems;
  final bool isRated;
  final bool isComplained;
  final double score;
  final String? ratingComment;
  final String? complaintDescription;
  final String? complaintCategory;
  final String? complaintPriority;
  final String? complaintPriorityLabel;
  final String? complaintDaysAgo;
  final String? complaintFormattedDate;
  final String? complaintWhatsappUrl;
  final String? complaintCallUrl;
  final String? receivedAt;
  final String? paidAt;
  final String immediatePremium;
  final List<String> beforeImages;
final List<String> afterImages;

  CompletedServiceModel({
    required this.id,
    required this.problemType,
    required this.status,
    required this.brand,
    required this.model,
    required this.year,
    required this.platenumber,
    required this.finalCost,
    required this.discountAmount,
    required this.discountPercentage,
    required this.subtotal,
    required this.subscription,
    required this.completedAt,
    required this.billItems,
    required this.isRated,
    required this.isComplained,
    required this.score,
    this.ratingComment,
    this.complaintDescription,
    this.complaintCategory,
    this.complaintPriority,
    this.complaintPriorityLabel,
    this.complaintDaysAgo,
    this.complaintFormattedDate,
    this.complaintWhatsappUrl,
    this.complaintCallUrl,
    this.receivedAt,
    this.paidAt,
    required this.immediatePremium,
    required this.beforeImages,
required this.afterImages,
  });

  factory CompletedServiceModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] is Map ? json['vehicle'] : {};
    final bill = json['bill'] is Map ? json['bill'] : {};
    final rating = json['rating_details'] is Map ? json['rating_details'] : {};
    final complaint = json['complaint_details'] is Map
        ? json['complaint_details']
        : {};

    return CompletedServiceModel(
      id: json['id'] ?? 0,
      problemType: json['problem_type'] ?? "unknown",
      status: json['status'] ?? "",
      brand: vehicle['brand'] ?? "Unknown",
      model: vehicle['model'] ?? "",
      year: vehicle['year']?.toString() ?? "",
      platenumber: vehicle['plate_number'] ?? "N/A",
      finalCost: bill['total_cost']?.toString() ?? "0",
      discountAmount: bill['discount_amount']?.toString() ?? "0",
      discountPercentage: bill['discount_percentage']?.toString() ?? "0",
      subtotal: bill['subtotal_cost']?.toString() ?? "0",
      subscription: bill['subscription'] ?? "None",
      completedAt: json['completed_request_at'] ?? json['created_at'] ?? "",
      billItems: bill['items'] ?? [],
      isRated: json['is_rated'] ?? false,
      isComplained: json['is_complained'] ?? false,
      score: (rating['score'] ?? 0).toDouble(),
      ratingComment: rating['comment'],
      complaintDescription:
          complaint['description'] ?? complaint['complaint_text'],
      complaintCategory: complaint['category'],
      complaintPriority: complaint['priority'],
      complaintPriorityLabel: complaint['priority_label'],
      complaintDaysAgo: complaint['days_ago'],
      complaintFormattedDate: complaint['formatted_date'],
      complaintWhatsappUrl: complaint['whatsapp_url'],
      complaintCallUrl: complaint['call_url'],
      receivedAt: json['received_at'],
      paidAt: bill['paid_at'],
      immediatePremium: bill['immediate_premium']?.toString() ?? "0",
  beforeImages: (json['before_images'] as List? ?? [])
    .map((e) => "${ApiConfig.base}${e['url']}")
    .toList(),

  afterImages: (json['after_images'] as List? ?? [])
    .map((e) => "${ApiConfig.base}${e['url']}")
    .toList(),
    );
  }
}
