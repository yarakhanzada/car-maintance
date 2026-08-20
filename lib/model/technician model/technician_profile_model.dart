class TechnicianProfileModel {
  final int? status;
  final TechnicianData? data;
  final String? message;

  TechnicianProfileModel({this.status, this.data, this.message});

  factory TechnicianProfileModel.fromJson(Map<String, dynamic> json) {
    return TechnicianProfileModel(
      status: json['status'],
      data: json['data'] != null ? TechnicianData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class TechnicianData {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String availabilityStatus;
  final String? availabilityStatusLabel;
  final Department? department;
  final TasksSummary? tasksSummary;
  final String memberSince;

  TechnicianData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.availabilityStatus,
    this.availabilityStatusLabel,
    this.department,
    this.tasksSummary,
    required this.memberSince,
  });

  factory TechnicianData.fromJson(Map<String, dynamic> json) {
    return TechnicianData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      availabilityStatus: json['availability_status'] ?? 'available',
      availabilityStatusLabel: json['availability_status_label'],
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
      tasksSummary: json['tasks_summary'] != null
          ? TasksSummary.fromJson(json['tasks_summary'])
          : null,
      memberSince: json['member_since'] ?? '',
    );
  }
}

class Department {
  final int id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class TasksSummary {
  final int total;
  final int completed;
  final int active;

  TasksSummary({
    required this.total,
    required this.completed,
    required this.active,
  });

  factory TasksSummary.fromJson(Map<String, dynamic> json) {
    return TasksSummary(
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      active: json['active'] ?? 0,
    );
  }
}
