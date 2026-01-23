import '../../core/constants/api_constants.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String? description;
  final String? logo;
  final String? coverImage;
  final double rating;
  final int reviewCount;
  final int totalOrders;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final int estimatedPrepTime; // in minutes
  final int deliveryFee;
  final int minOrderAmount;
  final bool isActive;
  final String? openTime;
  final String? closeTime;
  final List<dynamic>? categories;
  final List<dynamic>? reviews;
  final bool isFavorite;

  RestaurantModel({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.coverImage,
    this.rating = 0,
    this.reviewCount = 0,
    this.totalOrders = 0,
    this.address,
    this.latitude,
    this.longitude,
    this.distance,
    this.estimatedPrepTime = 30,
    this.deliveryFee = 0,
    this.minOrderAmount = 0,
    this.isActive = true,
    this.openTime,
    this.closeTime,
    this.categories,
    this.reviews,
    this.isFavorite = false,
  });

  // Helper getters
  /// ຮູບພາບທີ່ຈະໃຊ້ສະແດງ (ແປງເປັນ full URL)
  String get displayImage {
    final imageUrl = logo ?? coverImage;
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'https://via.placeholder.com/300x200?text=No+Image';
    }
    return ApiConstants.getImageUrl(imageUrl);
  }

  bool get hasImage => logo != null || coverImage != null;
  String get deliveryTimeText =>
      '$estimatedPrepTime-${estimatedPrepTime + 10} ນາທີ';
  String get deliveryFeeText => deliveryFee > 0
      ? '₭${deliveryFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
      : 'ຟຣີ';

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    // Handle _count object for reviewCount
    int reviewCount = 0;
    if (json['_count'] != null && json['_count']['reviews'] != null) {
      reviewCount = json['_count']['reviews'];
    } else if (json['reviewCount'] != null) {
      reviewCount = json['reviewCount'];
    } else if (json['review_count'] != null) {
      reviewCount = json['review_count'];
    }

    return RestaurantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      // Support both 'logo' and 'image' fields
      logo: json['logo'] ?? json['image'],
      // Support both camelCase and snake_case
      coverImage: json['coverImage'] ?? json['cover_image'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: reviewCount,
      totalOrders: json['totalOrders'] ?? json['total_orders'] ?? 0,
      address: json['address'],
      // Support both 'lat/lng' and 'latitude/longitude'
      latitude: (json['lat'] ?? json['latitude'])?.toDouble(),
      longitude: (json['lng'] ?? json['longitude'])?.toDouble(),
      distance: json['distance']?.toDouble(),
      // Support both camelCase and snake_case
      estimatedPrepTime:
          json['estimatedPrepTime'] ?? json['delivery_time'] ?? 30,
      deliveryFee: json['deliveryFee'] ?? json['delivery_fee'] ?? 0,
      minOrderAmount: json['minOrderAmount'] ?? json['min_order'] ?? 0,
      // Support both 'isActive' and 'is_open'
      isActive: json['isActive'] ?? json['is_open'] ?? true,
      openTime: json['openTime'] ?? json['open_time'],
      closeTime: json['closeTime'] ?? json['close_time'],
      // Categories can be objects or strings
      categories: json['categories'],
      reviews: json['reviews'],
      isFavorite: json['isFavorite'] ?? json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'coverImage': coverImage,
      'rating': rating,
      'reviewCount': reviewCount,
      'totalOrders': totalOrders,
      'address': address,
      'lat': latitude,
      'lng': longitude,
      'distance': distance,
      'estimatedPrepTime': estimatedPrepTime,
      'deliveryFee': deliveryFee,
      'minOrderAmount': minOrderAmount,
      'isActive': isActive,
      'openTime': openTime,
      'closeTime': closeTime,
      'categories': categories,
      'reviews': reviews,
      'isFavorite': isFavorite,
    };
  }

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logo,
    String? coverImage,
    double? rating,
    int? reviewCount,
    int? totalOrders,
    String? address,
    double? latitude,
    double? longitude,
    double? distance,
    int? estimatedPrepTime,
    int? deliveryFee,
    int? minOrderAmount,
    bool? isActive,
    String? openTime,
    String? closeTime,
    List<dynamic>? categories,
    List<dynamic>? reviews,
    bool? isFavorite,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalOrders: totalOrders ?? this.totalOrders,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      estimatedPrepTime: estimatedPrepTime ?? this.estimatedPrepTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      isActive: isActive ?? this.isActive,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      categories: categories ?? this.categories,
      reviews: reviews ?? this.reviews,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
