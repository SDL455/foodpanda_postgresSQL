import 'restaurant_model.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String storeId;
  final RestaurantModel? restaurant;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.storeId,
    this.restaurant,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      storeId: json['store_id'] ?? json['storeId'] ?? '',
      restaurant: json['store'] != null
          ? RestaurantModel.fromJson(json['store'])
          : (json['restaurant'] != null
              ? RestaurantModel.fromJson(json['restaurant'])
              : null),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_id': storeId,
      'store': restaurant?.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
