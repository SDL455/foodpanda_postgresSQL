class MenuItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final String? image;
  final double price;
  final double? originalPrice;
  final String? category;
  final bool isAvailable;
  final bool isPopular;
  final List<MenuOption>? options;

  MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    this.image,
    required this.price,
    this.originalPrice,
    this.category,
    this.isAvailable = true,
    this.isPopular = false,
    this.options,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get discountPercent {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? '',
      restaurantId: json['restaurant_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      category: json['category'],
      isAvailable: json['is_available'] ?? true,
      isPopular: json['is_popular'] ?? false,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((e) => MenuOption.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'original_price': originalPrice,
      'category': category,
      'is_available': isAvailable,
      'is_popular': isPopular,
      'options': options?.map((e) => e.toJson()).toList(),
    };
  }
}

class MenuOption {
  final String id;
  final String name;
  final bool isRequired;
  final int maxSelection;
  final List<OptionItem> items;

  MenuOption({
    required this.id,
    required this.name,
    this.isRequired = false,
    this.maxSelection = 1,
    required this.items,
  });

  factory MenuOption.fromJson(Map<String, dynamic> json) {
    return MenuOption(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isRequired: json['is_required'] ?? false,
      maxSelection: json['max_selection'] ?? 1,
      items: json['items'] != null
          ? (json['items'] as List).map((e) => OptionItem.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_required': isRequired,
      'max_selection': maxSelection,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class OptionItem {
  final String id;
  final String name;
  final double price;

  OptionItem({
    required this.id,
    required this.name,
    this.price = 0,
  });

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    return OptionItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}
