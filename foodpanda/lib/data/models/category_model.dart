class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? image;
  final int restaurantCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.image,
    this.restaurantCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      image: json['image'],
      restaurantCount: json['restaurant_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'image': image,
      'restaurant_count': restaurantCount,
    };
  }
}
