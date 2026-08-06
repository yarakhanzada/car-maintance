
class ServiceHistoryModel {
  int? status;
  List<ServiceData>? data;
  String? message;

  ServiceHistoryModel({this.status, this.data, this.message});

  ServiceHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <ServiceData>[];
      json['data'].forEach((v) {
        data!.add(ServiceData.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class ServiceData {
  int? id;
  int? userId;
  int? vehiclesId;
  String? problemType;
  String? status;
  String? createdAt;
  String? updatedAt;
  Vehicle? vehicle;
  TowingRequest? towingRequest;
  MaintenanceRequest? maintenanceRequest;
  List<RequestStatusHistory>? requestStatusHistory;

  ServiceData({
    this.id,
    this.userId,
    this.vehiclesId,
    this.problemType,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.vehicle,
    this.towingRequest,
    this.maintenanceRequest,
    this.requestStatusHistory,
  });

  ServiceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    vehiclesId = json['vehicles_id'];
    problemType = json['problem_type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    vehicle = json['vehicle'] != null
        ? Vehicle.fromJson(json['vehicle'])
        : null;
    towingRequest = json['towing_request'] != null
        ? TowingRequest.fromJson(json['towing_request'])
        : null;
    maintenanceRequest = json['maintenance_request'] != null
        ? MaintenanceRequest.fromJson(json['maintenance_request'])
        : null;
    if (json['request_status_history'] != null) {
      requestStatusHistory = <RequestStatusHistory>[];
      json['request_status_history'].forEach((v) {
        requestStatusHistory!.add(RequestStatusHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['vehicles_id'] = vehiclesId;
    data['problem_type'] = problemType;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (vehicle != null) data['vehicle'] = vehicle!.toJson();
    if (towingRequest != null) data['towing_request'] = towingRequest!.toJson();
    if (maintenanceRequest != null) {
      data['maintenance_request'] = maintenanceRequest!.toJson();
    }
    if (requestStatusHistory != null) {
      data['request_status_history'] = requestStatusHistory!
          .map((v) => v.toJson())
          .toList();
    }
    return data;
  }
}

class Vehicle {
  int? id;
  int? userId;
  String? brand;
  String? year;
  String? model;
  String? plate_number;
  String? createdAt;
  String? updatedAt;

  Vehicle({
    this.id,
    this.userId,
    this.brand,
    this.year,
    this.model,
    this.plate_number,
    this.createdAt,
    this.updatedAt,
  });

  Vehicle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    brand = json['brand'];
    year = json['year'];
    model = json['model'];
    plate_number = json['plate_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['brand'] = brand;
    data['year'] = year;
    data['model'] = model;
    data['plate_number'] = plate_number;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class TowingRequest {
  int? id;
  int? serviceRequestId;
  int? towTruckId;
  int? locationId;
  dynamic distance;
  String? departureTime;
  String? arrivalTime;
  String? completedAt;
  String? createdAt;
  String? updatedAt;
  Location? location;
  TowTruck? towTruck;

  TowingRequest({
    this.id,
    this.serviceRequestId,
    this.towTruckId,
    this.locationId,
    this.distance,
    this.departureTime,
    this.arrivalTime,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.location,
    this.towTruck,
  });

  TowingRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceRequestId = json['service_request_id'];
    towTruckId = json['tow_truck_id'];
    locationId = json['location_id'];
    distance = json['distance'];
    departureTime = json['departure_time'];
    arrivalTime = json['arrival_time'];
    completedAt = json['completed_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    towTruck = json['tow_truck'] != null
        ? TowTruck.fromJson(json['tow_truck'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_request_id'] = serviceRequestId;
    data['tow_truck_id'] = towTruckId;
    data['location_id'] = locationId;
    data['distance'] = distance;
    data['departure_time'] = departureTime;
    data['arrival_time'] = arrivalTime;
    data['completed_at'] = completedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (location != null) data['location'] = location!.toJson();
    if (towTruck != null) data['tow_truck'] = towTruck!.toJson();
    return data;
  }
}

class Location {
  int? id;
  int? userId;
  int? towTruckId;
  dynamic latitude;
  dynamic longitude;
  String? recordedAt;
  String? createdAt;
  String? updatedAt;

  Location({
    this.id,
    this.userId,
    this.towTruckId,
    this.latitude,
    this.longitude,
    this.recordedAt,
    this.createdAt,
    this.updatedAt,
  });

  Location.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    towTruckId = json['tow_truck_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    recordedAt = json['recorded_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['tow_truck_id'] = towTruckId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['recorded_at'] = recordedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class TowTruck {
  int? id;
  int? userId;
  String? chassisNumber;
  String? pricePerKm;
  String? availabilityStatus;
  String? createdAt;
  String? updatedAt;

  TowTruck({
    this.id,
    this.userId,
    this.chassisNumber,
    this.pricePerKm,
    this.availabilityStatus,
    this.createdAt,
    this.updatedAt,
  });

  TowTruck.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    chassisNumber = json['chassis_number'];
    pricePerKm = json['price_per_km'];
    availabilityStatus = json['availability_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['chassis_number'] = chassisNumber;
    data['price_per_km'] = pricePerKm;
    data['availability_status'] = availabilityStatus;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class MaintenanceRequest {
  int? id;
  int? serviceRequestId;
  String? scheduledDate;
  String? startedAt;
  String? completedAt;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? maintenance;

  MaintenanceRequest({
    this.id,
    this.serviceRequestId,
    this.scheduledDate,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.maintenance,
  });

  MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceRequestId = json['service_request_id'];
    scheduledDate = json['scheduled_date'];
    startedAt = json['started_at'];
    completedAt = json['completed_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['maintenance'] != null) {
      maintenance = [];
      json['maintenance'].forEach((v) {
        maintenance!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_request_id'] = serviceRequestId;
    data['scheduled_date'] = scheduledDate;
    data['started_at'] = startedAt;
    data['completed_at'] = completedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (maintenance != null) {
      data['maintenance'] = maintenance;
    }
    return data;
  }
}

class RequestStatusHistory {
  int? id;
  int? serviceRequestId;
  String? status;
  String? changedAt;

  RequestStatusHistory({
    this.id,
    this.serviceRequestId,
    this.status,
    this.changedAt,
  });

  RequestStatusHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceRequestId = json['service_request_id'];
    status = json['status'];
    changedAt = json['changed_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_request_id'] = serviceRequestId;
    data['status'] = status;
    data['changed_at'] = changedAt;
    return data;
  }
}
