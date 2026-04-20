class Department {
  final int id;
  final String name;
  final String description;
  final String image;

  Department({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] != null ? json['image']['path'] ?? '' : '',
    );
  }
}