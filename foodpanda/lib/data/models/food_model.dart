class FoodModel {
  final String id;
  final String name;
  final String? description;
  final int price;
  final String currency;
  final String? image;
  final bool isAvailable;
  final int totalSold;
  final bool isFavorite;
  final FoodCategory? category;
  final FoodStore store;
  final List<FoodVariant> variants;
  final List<FoodImage> images;

  FoodModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency = 'LAK',
    this.image,
    this.isAvailable = true,
    this.totalSold = 0,
    this.isFavorite = false,
    this.category,
    required this.store,
    this.variants = const [],
    this.images = const [],
  });

  /// ລາຄາທີ່ສະແດງ (ຟໍແມັດ)
  String get priceText => '${_formatNumber(price)} $currency';

  /// ຈຳນວນຂາຍທີ່ສະແດງ
  String get soldText => '$totalSold ຂາຍແລ້ວ';

  /// ຮູບພາບທີ່ຈະໃຊ້ສະແດງ
  String get displayImage {
    if (image != null && image!.isNotEmpty) return image!;
    if (images.isNotEmpty) return images.first.url;
    return 'https://via.placeholder.com/300x200?text=No+Image';
  }

  /// ມີ variants ຫຼືບໍ່
  bool get hasVariants => variants.isNotEmpty;

  /// variants ທີ່ available
  List<FoodVariant> get availableVariants =>
      variants.where((v) => v.isAvailable).toList();

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'LAK',
      image: json['image'],
      isAvailable: json['is_available'] ?? true,
      totalSold: json['total_sold'] ?? 0,
      isFavorite: json['is_favorite'] ?? json['isFavorite'] ?? false,
      category: json['category'] != null
          ? FoodCategory.fromJson(json['category'])
          : null,
      store: FoodStore.fromJson(json['store'] ?? {}),
      variants: json['variants'] != null
          ? (json['variants'] as List)
                .map((e) => FoodVariant.fromJson(e))
                .toList()
          : [],
      images: json['images'] != null
          ? (json['images'] as List).map((e) => FoodImage.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'image': image,
      'is_available': isAvailable,
      'total_sold': totalSold,
      'is_favorite': isFavorite,
      'category': category?.toJson(),
      'store': store.toJson(),
      'variants': variants.map((e) => e.toJson()).toList(),
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  FoodModel copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? currency,
    String? image,
    bool? isAvailable,
    int? totalSold,
    bool? isFavorite,
    FoodCategory? category,
    FoodStore? store,
    List<FoodVariant>? variants,
    List<FoodImage>? images,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      totalSold: totalSold ?? this.totalSold,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      store: store ?? this.store,
      variants: variants ?? this.variants,
      images: images ?? this.images,
    );
  }
}

class FoodCategory {
  final String id;
  final String name;

  FoodCategory({required this.id, required this.name});

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(id: json['id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class FoodStore {
  final String id;
  final String name;
  final String? logo;
  final String? coverImage;
  final double rating;
  final int deliveryFee;
  final int estimatedPrepTime;
  final int? minOrderAmount;
  final String? address;
  final String? openTime;
  final String? closeTime;

  FoodStore({
    required this.id,
    required this.name,
    this.logo,
    this.coverImage,
    this.rating = 0,
    this.deliveryFee = 0,
    this.estimatedPrepTime = 30,
    this.minOrderAmount,
    this.address,
    this.openTime,
    this.closeTime,
  });

  /// ຄ່າສົ່ງທີ່ສະແດງ
  String get deliveryFeeText =>
      deliveryFee > 0 ? '${_formatNumber(deliveryFee)} ກີບ' : 'ສົ່ງຟຣີ';

  /// ເວລາກະກຽມທີ່ສະແດງ
  String get prepTimeText => '$estimatedPrepTime ນາທີ';

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  factory FoodStore.fromJson(Map<String, dynamic> json) {
    return FoodStore(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      coverImage: json['cover_image'],
      rating: (json['rating'] ?? 0).toDouble(),
      deliveryFee: json['delivery_fee'] ?? 0,
      estimatedPrepTime: json['estimated_prep_time'] ?? 30,
      minOrderAmount: json['min_order_amount'],
      address: json['address'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'cover_image': coverImage,
      'rating': rating,
      'delivery_fee': deliveryFee,
      'estimated_prep_time': estimatedPrepTime,
      'min_order_amount': minOrderAmount,
      'address': address,
      'open_time': openTime,
      'close_time': closeTime,
    };
  }
}

class FoodVariant {
  final String id;
  final String name;
  final int priceDelta;
  final bool isAvailable;

  FoodVariant({
    required this.id,
    required this.name,
    this.priceDelta = 0,
    this.isAvailable = true,
  });

  /// ລາຄາເພີ່ມທີ່ສະແດງ
  String get priceDeltaText =>
      priceDelta > 0 ? '+${_formatNumber(priceDelta)} ກີບ' : '';

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  factory FoodVariant.fromJson(Map<String, dynamic> json) {
    return FoodVariant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      priceDelta: json['price_delta'] ?? 0,
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_delta': priceDelta,
      'is_available': isAvailable,
    };
  }
}

class FoodImage {
  final String id;
  final String url;
  final int sortOrder;

  FoodImage({required this.id, required this.url, this.sortOrder = 0});

  factory FoodImage.fromJson(Map<String, dynamic> json) {
    return FoodImage(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'sort_order': sortOrder};
  }
}
