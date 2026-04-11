class ResetPasswordResponse {
  final int status;
  final String message;

  ResetPasswordResponse({required this.status, required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      status: json['status'],
      message: json['message'],
    );
  }
}
