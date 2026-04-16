class UpdateProfileModel {
  final String name;
  final String phone;

  UpdateProfileModel({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
    };
  }
}