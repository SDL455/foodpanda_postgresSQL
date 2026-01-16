class RestaurantModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? coverImage;
  final double rating;
  final int reviewCount;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final int deliveryTime; // in minutes
  final double deliveryFee;
  final double minOrder;
  final bool isOpen;
  final String? openTime;
  final String? closeTime;
  final List<String> categories;
  final bool isFavorite;

  RestaurantModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.coverImage,
    this.rating = 0,
    this.reviewCount = 0,
    this.address,
    this.latitude,
    this.longitude,
    this.distance,
    this.deliveryTime = 30,
    this.deliveryFee = 0,
    this.minOrder = 0,
    this.isOpen = true,
    this.openTime,
    this.closeTime,
    this.categories = const [],
    this.isFavorite = false,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      coverImage: json['cover_image'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      distance: json['distance']?.toDouble(),
      deliveryTime: json['delivery_time'] ?? 30,
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      minOrder: (json['min_order'] ?? 0).toDouble(),
      isOpen: json['is_open'] ?? true,
      openTime: json['open_time'],
      closeTime: json['close_time'],
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'cover_image': coverImage,
      'rating': rating,
      'review_count': reviewCount,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'delivery_time': deliveryTime,
      'delivery_fee': deliveryFee,
      'min_order': minOrder,
      'is_open': isOpen,
      'open_time': openTime,
      'close_time': closeTime,
      'categories': categories,
      'is_favorite': isFavorite,
    };
  }

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? coverImage,
    double? rating,
    int? reviewCount,
    String? address,
    double? latitude,
    double? longitude,
    double? distance,
    int? deliveryTime,
    double? deliveryFee,
    double? minOrder,
    bool? isOpen,
    String? openTime,
    String? closeTime,
    List<String>? categories,
    bool? isFavorite,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      coverImage: coverImage ?? this.coverImage,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrder: minOrder ?? this.minOrder,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      categories: categories ?? this.categories,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
