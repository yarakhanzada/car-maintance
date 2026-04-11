class VerifyModel {
  final int status;
  final String message;

  VerifyModel({required this.status, required this.message});

  factory VerifyModel.fromJson(Map<String, dynamic> json) {
    return VerifyModel(status: json['status'], message: json['message']);
  }
}
