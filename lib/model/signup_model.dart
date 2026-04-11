class SignUpModel {
  final int status;
  final String message;
  final UserData data;

  SignUpModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      status: json['status'],
      message: json['message'],
      data: UserData.fromJson(json['data']),
    );
  }
}

class UserData {
  final String name;
  final String email;
  final String phone;
  final int verifiedCode;
  final int id;

  UserData({
    required this.name,
    required this.email,
    required this.phone,
    required this.verifiedCode,
    required this.id,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      verifiedCode: json['verified_code'],
      id: json['id'],
    );
  }
}