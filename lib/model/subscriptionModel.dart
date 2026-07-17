class SubscriptionModel {
  int? id;
  String? name;
  String? price;
  String? discountPercentage;
  String? description;
  int? inspectionsCount;
  int? duration;
  String? imageUrl;

  SubscriptionModel({
    this.id,
    this.name,
    this.price,
    this.discountPercentage,
    this.description,
    this.inspectionsCount,
    this.duration,
    this.imageUrl,
  });

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    discountPercentage = json['discount_percentage'];
    description = json['description'];
    inspectionsCount = json['periodic_inspections_count'];
    duration = json['duration'];
    imageUrl = json['image_url'];
  }
}
