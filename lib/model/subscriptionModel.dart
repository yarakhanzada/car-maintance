class SubscriptionModel {
  int? id;
  String? name;
  String? tier;
  String? price;
  String? discountPercentage;
  String? description;

  int? inspectionsCount;
  bool? includesPeriodicMaintenance;
  bool? includesOfferNotifications;
  bool? includesStatusNotifications;
  int? maintenanceReminderHours;

  String? status;
  String? statusLabel;

  int? duration;

  int? freeOilChanges;
  bool? freeSparkPlugs;
  bool? sparkPlugsIncludesParts;
  bool? freeBrakePadsLabor;
  int? freeComputerInspections;
  bool? freeMechanicInspection;
  int? freeGeneralCheckups;

  String? laborDiscountPercentage;
  String? partsDiscountPercentage;

  String? createdAt;
  String? updatedAt;

  String? imageUrl;

  List<String> directBenefits = [];
  List<String> permanentDiscounts = [];

  SubscriptionModel({
    this.id,
    this.name,
    this.tier,
    this.price,
    this.discountPercentage,
    this.description,
    this.inspectionsCount,
    this.includesPeriodicMaintenance,
    this.includesOfferNotifications,
    this.includesStatusNotifications,
    this.maintenanceReminderHours,
    this.status,
    this.statusLabel,
    this.duration,
    this.freeOilChanges,
    this.freeSparkPlugs,
    this.sparkPlugsIncludesParts,
    this.freeBrakePadsLabor,
    this.freeComputerInspections,
    this.freeMechanicInspection,
    this.freeGeneralCheckups,
    this.laborDiscountPercentage,
    this.partsDiscountPercentage,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
  });

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    tier = json['tier'];
    price = json['price'];
    discountPercentage = json['discount_percentage'];
    description = json['description'];

    inspectionsCount = json['periodic_inspections_count'];
    includesPeriodicMaintenance = json['includes_periodic_maintenance'];
    includesOfferNotifications = json['includes_offer_notifications'];
    includesStatusNotifications = json['includes_status_notifications'];
    maintenanceReminderHours = json['maintenance_reminder_hours'];

    status = json['status'];
    statusLabel = json['status_label'];

    duration = json['duration'];

    freeOilChanges = json['free_oil_changes'];
    freeSparkPlugs = json['free_spark_plugs'];
    sparkPlugsIncludesParts = json['spark_plugs_includes_parts'];
    freeBrakePadsLabor = json['free_brake_pads_labor'];
    freeComputerInspections = json['free_computer_inspections'];
    freeMechanicInspection = json['free_mechanic_inspection'];
    freeGeneralCheckups = json['free_general_checkups'];

    laborDiscountPercentage = json['labor_discount_percentage'];
    partsDiscountPercentage = json['parts_discount_percentage'];

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    imageUrl = json['image_url'];

    if (json['benefits_summary'] != null) {
      directBenefits = List<String>.from(
        json['benefits_summary']['direct_benefits'] ?? [],
      );

      permanentDiscounts = List<String>.from(
        json['benefits_summary']['permanent_discounts'] ?? [],
      );
    }
  }
}
