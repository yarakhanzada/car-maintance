class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String status;
  final List<String> roles;
  final List<String> permissions;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.roles,
    required this.permissions,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }
}