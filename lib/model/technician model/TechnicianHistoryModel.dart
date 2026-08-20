class TechnicianHistoryModel {
  final int status;
  final List<HistoryTask> data;
  final String message;

  TechnicianHistoryModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory TechnicianHistoryModel.fromJson(Map<String, dynamic> json) {
    return TechnicianHistoryModel(
      status: json['status'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => HistoryTask.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
    );
  }
}

class HistoryTask {
  final int id;
  final int maintenanceRequestId;
  final int departmentId;
  final String startDate;
  final String endDate;
  final String status;
  final String? statusLabel;
  final int priority;
  final int estimatedTime;
  final String notes;
  final MaintenanceRequest? maintenanceRequest;
  final List<MaintenanceTechnicianElement> maintenanceTechnician;
  final Department? department;
  final String enteredAt;
final String exitedAt;


  HistoryTask({
    required this.id,
    required this.maintenanceRequestId,
    required this.departmentId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.statusLabel,
    required this.priority,
    required this.estimatedTime,
    required this.notes,
    this.maintenanceRequest,
    required this.maintenanceTechnician,
    this.department,
    required this.enteredAt,
    required this.exitedAt,
  });

  factory HistoryTask.fromJson(Map<String, dynamic> json) {
    return HistoryTask(
      id: json['id'] ?? 0,
      maintenanceRequestId: json['maintenance_request_id'] ?? 0,
      departmentId: json['department_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'],
      priority: json['priority'] ?? 0,
      estimatedTime: json['estimated_time'] ?? 0,
      notes: json['notes'] ?? '',
      maintenanceRequest: json['maintenance_request'] != null
          ? MaintenanceRequest.fromJson(json['maintenance_request'])
          : null,
      maintenanceTechnician: (json['maintenance_technician'] as List? ?? [])
          .map((e) => MaintenanceTechnicianElement.fromJson(e))
          .toList(),
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
          enteredAt: json['entered_at'] ?? '',
         exitedAt: json['exited_at'] ?? '',
    );
  }
}

class MaintenanceRequest {
  final int id;
  final int serviceRequestId;
  final int estimatedDurationMinutes;
  final String engineerNotes;
  final String startedAt;
  final String completedAt;
  final ServiceRequest? serviceRequest;

  MaintenanceRequest({
    required this.id,
    required this.serviceRequestId,
    required this.estimatedDurationMinutes,
    required this.engineerNotes,
    required this.startedAt,
    required this.completedAt,
    this.serviceRequest,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] ?? 0,
      serviceRequestId: json['service_request_id'] ?? 0,
      estimatedDurationMinutes: json['estimated_duration_minutes'] ?? 0,
      engineerNotes: json['engineer_notes'] ?? '',
      startedAt: json['started_at'] ?? '',
      completedAt: json['completed_at'] ?? '',
      serviceRequest: json['service_request'] != null
          ? ServiceRequest.fromJson(json['service_request'])
          : null,
    );
  }
}

class ServiceRequest {
  final int id;
  final int userId;
  final int vehiclesId;
  final String problemType;
  final String status;
  final String receivedAt;
  final HistoryUser? user;
  final HistoryVehicle? vehicle;

  ServiceRequest({
    required this.id,
    required this.userId,
    required this.vehiclesId,
    required this.problemType,
    required this.status,
    required this.receivedAt,
    this.user,
    this.vehicle,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      vehiclesId: json['vehicles_id'] ?? 0,
      problemType: json['problem_type'] ?? '',
      status: json['status'] ?? '',
      receivedAt: json['received_at'] ?? '',
      user: json['user'] != null ? HistoryUser.fromJson(json['user']) : null,
      vehicle: json['vehicle'] != null
          ? HistoryVehicle.fromJson(json['vehicle'])
          : null,
    );
  }
}

class HistoryUser {
  final int id;
  final String name;
  final String phone;

  HistoryUser({required this.id, required this.name, required this.phone});

  factory HistoryUser.fromJson(Map<String, dynamic> json) {
    return HistoryUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class HistoryVehicle {
  final int id;
  final String brand;
  final String model;
  final String year;
  final String plateNumber;

  HistoryVehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
  });

  factory HistoryVehicle.fromJson(Map<String, dynamic> json) {
    return HistoryVehicle(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year']?.toString() ?? '',
      plateNumber: json['plate_number'] ?? '',
    );
  }
}

class MaintenanceTechnicianElement {
  final int id;
  final int maintenanceId;
  final int technicianId;

  MaintenanceTechnicianElement({
    required this.id,
    required this.maintenanceId,
    required this.technicianId,
  });

  factory MaintenanceTechnicianElement.fromJson(Map<String, dynamic> json) {
    return MaintenanceTechnicianElement(
      id: json['id'] ?? 0,
      maintenanceId: json['maintenance_id'] ?? 0,
      technicianId: json['technician_id'] ?? 0,
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
