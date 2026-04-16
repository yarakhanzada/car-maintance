class SignUpModel {
  final int status;
  final String message;
  final String? email;

  SignUpModel({
    required this.status,
    required this.message,
    this.email,
  });

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      status: json["status"],
      message: json["message"],
      email: json["data"]?["email"],
    );
  }
}