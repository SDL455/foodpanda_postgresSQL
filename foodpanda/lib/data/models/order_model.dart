import 'cart_item_model.dart';
import 'restaurant_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  onTheWay,
  delivered,
  cancelled,
}

class OrderModel {
  final String id;
  final String userId;
  final RestaurantModel restaurant;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final OrderStatus status;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? paymentMethod;
  final bool isPaid;
  final String? note;
  final String? driverName;
  final String? driverPhone;
  final double? driverLatitude;
  final double? driverLongitude;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.restaurant,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    required this.total,
    this.status = OrderStatus.pending,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.paymentMethod,
    this.isPaid = false,
    this.note,
    this.driverName,
    this.driverPhone,
    this.driverLatitude,
    this.driverLongitude,
    required this.createdAt,
    this.estimatedDelivery,
    this.deliveredAt,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'ລໍຖ້າຢືນຢັນ';
      case OrderStatus.confirmed:
        return 'ຢືນຢັນແລ້ວ';
      case OrderStatus.preparing:
        return 'ກຳລັງກະກຽມ';
      case OrderStatus.ready:
        return 'ພ້ອມສົ່ງ';
      case OrderStatus.onTheWay:
        return 'ກຳລັງສົ່ງ';
      case OrderStatus.delivered:
        return 'ສົ່ງແລ້ວ';
      case OrderStatus.cancelled:
        return 'ຍົກເລີກແລ້ວ';
    }
  }

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  bool get isActive =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      restaurant: RestaurantModel.fromJson(json['restaurant']),
      items: (json['items'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryLatitude: json['delivery_latitude']?.toDouble(),
      deliveryLongitude: json['delivery_longitude']?.toDouble(),
      paymentMethod: json['payment_method'],
      isPaid: json['is_paid'] ?? false,
      note: json['note'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      driverLatitude: json['driver_latitude']?.toDouble(),
      driverLongitude: json['driver_longitude']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant': restaurant.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'discount': discount,
      'total': total,
      'status': status.name,
      'delivery_address': deliveryAddress,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'payment_method': paymentMethod,
      'is_paid': isPaid,
      'note': note,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'driver_latitude': driverLatitude,
      'driver_longitude': driverLongitude,
      'created_at': createdAt.toIso8601String(),
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }
}
