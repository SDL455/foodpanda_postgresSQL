class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? avatar;
  final String? authProvider;
  final String? fcmToken;
  final int? totalOrders;
  final int? totalFavorites;
  final int? totalReviews;
  final double? totalSpent;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.avatar,
    this.authProvider,
    this.fcmToken,
    this.totalOrders,
    this.totalFavorites,
    this.totalReviews,
    this.totalSpent,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  // Get display name
  String get displayName => fullName ?? email ?? 'ຜູ້ໃຊ້';

  // Get initials for avatar
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!.substring(0, 1).toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'],
      // Support both 'fullName' and 'name' fields
      fullName: json['fullName'] ?? json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      authProvider: json['authProvider'],
      fcmToken: json['fcmToken'] ?? json['fcm_token'],
      totalOrders: json['_count']?['orders'] ?? json['totalOrders'],
      totalFavorites: json['_count']?['favorites'] ?? json['totalFavorites'],
      totalReviews: json['_count']?['reviews'] ?? json['totalReviews'],
      totalSpent: json['totalSpent']?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'avatar': avatar,
      'authProvider': authProvider,
      'fcmToken': fcmToken,
      'totalOrders': totalOrders,
      'totalFavorites': totalFavorites,
      'totalReviews': totalReviews,
      'totalSpent': totalSpent,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatar,
    String? authProvider,
    String? fcmToken,
    int? totalOrders,
    int? totalFavorites,
    int? totalReviews,
    double? totalSpent,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      authProvider: authProvider ?? this.authProvider,
      fcmToken: fcmToken ?? this.fcmToken,
      totalOrders: totalOrders ?? this.totalOrders,
      totalFavorites: totalFavorites ?? this.totalFavorites,
      totalReviews: totalReviews ?? this.totalReviews,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
