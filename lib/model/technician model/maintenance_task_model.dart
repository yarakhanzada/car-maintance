class MaintenanceTaskResponse {
  final int status;
  final List<MaintenanceTask> data;
  final String message;

  MaintenanceTaskResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory MaintenanceTaskResponse.fromJson(Map<String, dynamic> json) {
    return MaintenanceTaskResponse(
      status: json['status'] ?? 0,
      data:
          (json['data'] as List?)
              ?.map((e) => MaintenanceTask.fromJson(e))
              .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }
}

class MaintenanceTask {
  final int id;
  final int maintenanceRequestId;
  final int departmentId;
  final String startDate;
  final String? endDate;
  final String status;
  final int priority;
  final String? notes;
  final MaintenanceRequest? maintenanceRequest;
  final Department? department;
  final Inspection? inspection;

  MaintenanceTask({
    required this.id,
    required this.maintenanceRequestId,
    required this.departmentId,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.priority,
    this.notes,
    this.maintenanceRequest,
    this.department,
    this.inspection,
  });

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      id: json['id'] ?? 0,
      maintenanceRequestId: json['maintenance_request_id'] ?? 0,
      departmentId: json['department_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 1,
      notes: json['notes'],
      maintenanceRequest: json['maintenance_request'] != null
          ? MaintenanceRequest.fromJson(json['maintenance_request'])
          : null,
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
      inspection: json['inspection'] != null
          ? Inspection.fromJson(json['inspection'])
          : null,
    );
  }
}

class MaintenanceRequest {
  final int id;
  final String scheduledDate;
  final String scheduledTime;
  final String startedAt;
  final ServiceRequest? serviceRequest;

  MaintenanceRequest({
    required this.id,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.startedAt,
    this.serviceRequest,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] ?? 0,
      scheduledDate: json['scheduled_date'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      startedAt: json['started_at'] ?? '',
      serviceRequest: json['service_request'] != null
          ? ServiceRequest.fromJson(json['service_request'])
          : null,
    );
  }
}

class ServiceRequest {
  final int id;
  final String problemType;
  final String status;
  final CustomerUser? user;
  final Vehicle? vehicle;

  ServiceRequest({
    required this.id,
    required this.problemType,
    required this.status,
    this.user,
    this.vehicle,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] ?? 0,
      problemType: json['problem_type'] ?? '',
      status: json['status'] ?? '',
      user: json['user'] != null ? CustomerUser.fromJson(json['user']) : null,
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'])
          : null,
    );
  }
}

class CustomerUser {
  final int id;
  final String name;
  final String phone;

  CustomerUser({required this.id, required this.name, required this.phone});

  factory CustomerUser.fromJson(Map<String, dynamic> json) {
    return CustomerUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'زبون',
      phone: json['phone'] ?? '',
    );
  }
}

class Vehicle {
  final int id;
  final String brand;
  final String year;
  final String model;
  final String plateNumber;

  Vehicle({
    required this.id,
    required this.brand,
    required this.year,
    required this.model,
    required this.plateNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      year: json['year'] ?? '',
      model: json['model'] ?? '',
      plateNumber: json['plate_number'] ?? '',
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

class Inspection {
  final int id;
  final String? notes;
  final List<Fault> faults;

  Inspection({required this.id, this.notes, required this.faults});

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'] ?? 0,
      notes: json['notes'],
      faults:
          (json['faults'] as List?)?.map((e) => Fault.fromJson(e)).toList() ??
          [],
    );
  }
}

class Fault {
  final int id;
  final String faultName;
  final String description;
  final String cost;
  final int time;

  Fault({
    required this.id,
    required this.faultName,
    required this.description,
    required this.cost,
    required this.time,
  });

  factory Fault.fromJson(Map<String, dynamic> json) {
    return Fault(
      id: json['id'] ?? 0,
      faultName: json['fault_name'] ?? '',
      description: json['description'] ?? '',
      cost: json['cost'] ?? '0.00',
      time: json['time'] ?? 0,
    );
  }
}
