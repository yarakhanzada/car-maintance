class TaskDetailsResponse {
  final int status;
  final MaintenanceTaskDetails? data;
  final String message;

  TaskDetailsResponse({required this.status, this.data, required this.message});

  factory TaskDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TaskDetailsResponse(
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status'].toString()) ?? 0,
      data: json['data'] != null
          ? MaintenanceTaskDetails.fromJson(json['data'])
          : null,
      message: json['message']?.toString() ?? '',
    );
  }
}

class MaintenanceTaskDetails {
  final int id;
  final int? maintenanceRequestId;
  final int? departmentId;
  final String? startDate;
  final String? endDate;
  final String status;
  final int? priority;
  final String? estimatedTime;
  final String? notes;
  final MaintenanceRequest? maintenanceRequest;
  final List<MaintenanceTechnician> maintenanceTechnicians;
  final Department? department;
  final Inspection? inspection;

  MaintenanceTaskDetails({
    required this.id,
    this.maintenanceRequestId,
    this.departmentId,
    this.startDate,
    this.endDate,
    required this.status,
    this.priority,
    this.estimatedTime,
    this.notes,
    this.maintenanceRequest,
    required this.maintenanceTechnicians,
    this.department,
    this.inspection,
  });

  factory MaintenanceTaskDetails.fromJson(Map<String, dynamic> json) {
    var techniciansList = json['maintenance_technician'] as List?;
    return MaintenanceTaskDetails(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      maintenanceRequestId: json['maintenance_request_id'] is int
          ? json['maintenance_request_id']
          : int.tryParse(json['maintenance_request_id'].toString()),
      departmentId: json['department_id'] is int
          ? json['department_id']
          : int.tryParse(json['department_id'].toString()),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      priority: json['priority'] is int
          ? json['priority']
          : int.tryParse(json['priority'].toString()),
      estimatedTime: json['estimated_time']?.toString(),
      notes: json['notes']?.toString(),
      maintenanceRequest: json['maintenance_request'] != null
          ? MaintenanceRequest.fromJson(json['maintenance_request'])
          : null,
      maintenanceTechnicians: techniciansList != null
          ? techniciansList
                .map((t) => MaintenanceTechnician.fromJson(t))
                .toList()
          : [],
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
  final ServiceRequest? serviceRequest;
  final String? totalEstimatedCost;
  final String? finalTotalCost;

  MaintenanceRequest({
    required this.id,
    this.serviceRequest,
    this.totalEstimatedCost,
    this.finalTotalCost,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      serviceRequest: json['service_request'] != null
          ? ServiceRequest.fromJson(json['service_request'])
          : null,
      totalEstimatedCost: json['total_estimated_cost']?.toString(),
      finalTotalCost: json['final_total_cost']?.toString(),
    );
  }
}

class ServiceRequest {
  final int id;
  final String? problemType;
  final String? status;
  final User? user;
  final Vehicle? vehicle;

  ServiceRequest({
    required this.id,
    this.problemType,
    this.status,
    this.user,
    this.vehicle,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      problemType: json['problem_type']?.toString(),
      status: json['status']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'])
          : null,
    );
  }
}

class User {
  final int id;
  final String name;
  final String? phone;

  User({required this.id, required this.name, this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString(),
    );
  }
}

class Vehicle {
  final int id;
  final String? brand;
  final String? model;
  final String? year;
  final String? plateNumber;

  Vehicle({
    required this.id,
    this.brand,
    this.model,
    this.year,
    this.plateNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      year: json['year']?.toString(),
      plateNumber: json['plate_number']?.toString(),
    );
  }
}

class MaintenanceTechnician {
  final int id;
  final TechnicianDetails? technician;

  MaintenanceTechnician({required this.id, this.technician});

  factory MaintenanceTechnician.fromJson(Map<String, dynamic> json) {
    return MaintenanceTechnician(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      technician: json['technician'] != null
          ? TechnicianDetails.fromJson(json['technician'])
          : null,
    );
  }
}

class TechnicianDetails {
  final int id;
  final String? availabilityStatus;
  final User? user;
  final Department? department;

  TechnicianDetails({
    required this.id,
    this.availabilityStatus,
    this.user,
    this.department,
  });

  factory TechnicianDetails.fromJson(Map<String, dynamic> json) {
    return TechnicianDetails(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      availabilityStatus: json['availability_status']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
    );
  }
}

class Department {
  final int id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class Inspection {
  final int id;
  final String? notes;
  final User? user;
  final List<Fault> faults;

  Inspection({required this.id, this.notes, this.user, required this.faults});

  factory Inspection.fromJson(Map<String, dynamic> json) {
    var faultsList = json['faults'] as List?;
    return Inspection(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      notes: json['notes']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      faults: faultsList != null
          ? faultsList.map((f) => Fault.fromJson(f)).toList()
          : [],
    );
  }
}

class Fault {
  final int id;
  final String faultName;
  final String description;
  final int? time;
  final List<SparePart> spareParts;
  final List<LaborService> laborServices;

  Fault({
    required this.id,
    required this.faultName,
    required this.description,
    this.time,
    required this.spareParts,
    required this.laborServices,
  });

  factory Fault.fromJson(Map<String, dynamic> json) {
    var parts = json['spare_parts'] as List?;
    var services = json['labor_services'] as List?;
    return Fault(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      faultName: json['fault_name']?.toString() ?? 'Unknown Fault',
      description: json['description']?.toString() ?? '',
      time: json['time'] is int
          ? json['time']
          : int.tryParse(json['time'].toString()),
      spareParts: parts != null
          ? parts.map((p) => SparePart.fromJson(p)).toList()
          : [],
      laborServices: services != null
          ? services.map((s) => LaborService.fromJson(s)).toList()
          : [],
    );
  }
}

class SparePart {
  final int id;
  final String name;
  final String? price;
  final String? description;
  final PartPivot? pivot;

  SparePart({
    required this.id,
    required this.name,
    this.price,
    this.description,
    this.pivot,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString(),
      description: json['description']?.toString(),
      pivot: json['pivot'] != null ? PartPivot.fromJson(json['pivot']) : null,
    );
  }
}

class PartPivot {
  final int? quantity;
  final String? unitPrice;
  final String? totalPrice;

  PartPivot({this.quantity, this.unitPrice, this.totalPrice});

  factory PartPivot.fromJson(Map<String, dynamic> json) {
    return PartPivot(
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()),
      unitPrice: json['unit_price']?.toString(),
      totalPrice: json['total_price']?.toString(),
    );
  }
}

class LaborService {
  final int id;
  final String name;
  final String? price;
  final ServicePivot? pivot;

  LaborService({required this.id, required this.name, this.price, this.pivot});

  factory LaborService.fromJson(Map<String, dynamic> json) {
    return LaborService(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString(),
      pivot: json['pivot'] != null
          ? ServicePivot.fromJson(json['pivot'])
          : null,
    );
  }
}

class ServicePivot {
  final int? quantity;
  final String? unitPrice;
  final String? totalPrice;

  ServicePivot({this.quantity, this.unitPrice, this.totalPrice});

  factory ServicePivot.fromJson(Map<String, dynamic> json) {
    return ServicePivot(
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()),
      unitPrice: json['unit_price']?.toString(),
      totalPrice: json['total_price']?.toString(),
    );
  }
}
