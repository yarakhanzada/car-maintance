class SignUpModel {
  final int status;
  final String message;
  final int id;

  SignUpModel({
    required this.status,
    required this.message,
    required this.id,
  });

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      status: json["status"],
      message: json["message"],
      id: json["data"]["id"],
    );
  }
}