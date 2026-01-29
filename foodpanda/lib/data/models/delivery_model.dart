/// Delivery status enum
enum DeliveryStatus {
  pending('PENDING', 'ລໍຖ້າຮັບ'),
  readyForPickup('READY_FOR_PICKUP', 'ພ້ອມສົ່ງ'),
  pickedUp('PICKED_UP', 'ຮັບແລ້ວ'),
  delivering('DELIVERING', 'ກຳລັງສົ່ງ'),
  delivered('DELIVERED', 'ສົ່ງສຳເລັດ'),
  cancelled('CANCELLED', 'ຍົກເລີກ');

  const DeliveryStatus(this.value, this.label);
  final String value;
  final String label;

  static DeliveryStatus fromString(String? status) {
    return DeliveryStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => DeliveryStatus.pending,
    );
  }
}

/// Order item model for delivery
class DeliveryOrderItem {
  final String name;
  final int quantity;
  final String? image;

  DeliveryOrderItem({
    required this.name,
    required this.quantity,
    this.image,
  });

  factory DeliveryOrderItem.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      image: json['image'],
    );
  }
}

/// Delivery model for rider app
class DeliveryModel {
  final String id;
  final String orderId;
  final String orderNo;
  final DeliveryStatus status;

  // Customer info
  final String customerName;
  final String customerPhone;
  final String? customerAvatar;
  final String customerAddress;
  final double customerLat;
  final double customerLng;
  final String? deliveryNote;

  // Store info
  final String storeName;
  final String? storePhone;
  final String? storeLogo;
  final String? storeAddress;
  final double? storeLat;
  final double? storeLng;

  // Order items
  final List<DeliveryOrderItem> items;
  final int itemCount;

  // Prices
  final int subtotal;
  final int deliveryFee;
  final int total;

  // Payment
  final String paymentMethod;
  final String paymentStatus;

  // Delivery info
  final double? distance;
  final int? estimatedTime;

  // Timestamps
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  DeliveryModel({
    required this.id,
    required this.orderId,
    required this.orderNo,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    this.customerAvatar,
    required this.customerAddress,
    required this.customerLat,
    required this.customerLng,
    this.deliveryNote,
    required this.storeName,
    this.storePhone,
    this.storeLogo,
    this.storeAddress,
    this.storeLat,
    this.storeLng,
    required this.items,
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    this.distance,
    this.estimatedTime,
    required this.createdAt,
    this.confirmedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? json['order_id'] ?? '',
      orderNo: json['orderNo'] ?? json['order_no'] ?? '',
      status: DeliveryStatus.fromString(json['status']),
      customerName: json['customerName'] ?? json['customer_name'] ?? 'ລູກຄ້າ',
      customerPhone: json['customerPhone'] ?? json['customer_phone'] ?? '',
      customerAvatar: json['customerAvatar'] ?? json['customer_avatar'],
      customerAddress:
          json['customerAddress'] ?? json['customer_address'] ?? '',
      customerLat: _toDouble(json['customerLat'] ?? json['customer_lat']),
      customerLng: _toDouble(json['customerLng'] ?? json['customer_lng']),
      deliveryNote: json['deliveryNote'] ?? json['delivery_note'],
      storeName: json['storeName'] ?? json['store_name'] ?? '',
      storePhone: json['storePhone'] ?? json['store_phone'],
      storeLogo: json['storeLogo'] ?? json['store_logo'],
      storeAddress: json['storeAddress'] ?? json['store_address'],
      storeLat: _toDoubleNullable(json['storeLat'] ?? json['store_lat']),
      storeLng: _toDoubleNullable(json['storeLng'] ?? json['store_lng']),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => DeliveryOrderItem.fromJson(e))
              .toList() ??
          [],
      itemCount: json['itemCount'] ?? json['item_count'] ?? 0,
      subtotal: json['subtotal'] ?? 0,
      deliveryFee: json['deliveryFee'] ?? json['delivery_fee'] ?? 0,
      total: json['total'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'CASH',
      paymentStatus:
          json['paymentStatus'] ?? json['payment_status'] ?? 'PENDING',
      distance: _toDoubleNullable(json['distance']),
      estimatedTime: json['estimatedTime'] ?? json['estimated_time'],
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      confirmedAt:
          _parseDateTimeNullable(json['confirmedAt'] ?? json['confirmed_at']),
      pickedUpAt:
          _parseDateTimeNullable(json['pickedUpAt'] ?? json['picked_up_at']),
      deliveredAt:
          _parseDateTimeNullable(json['deliveredAt'] ?? json['delivered_at']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    return _toDouble(value);
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.parse(value.toString());
  }

  static DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  /// Check if delivery can be accepted
  bool get canAccept => status == DeliveryStatus.readyForPickup;

  /// Check if delivery is active
  bool get isActive =>
      status == DeliveryStatus.pickedUp || status == DeliveryStatus.delivering;

  /// Check if delivery is completed
  bool get isCompleted => status == DeliveryStatus.delivered;

  /// Get next status
  DeliveryStatus? get nextStatus {
    switch (status) {
      case DeliveryStatus.pickedUp:
        return DeliveryStatus.delivering;
      case DeliveryStatus.delivering:
        return DeliveryStatus.delivered;
      default:
        return null;
    }
  }

  /// Get action text for current status
  String get actionText {
    switch (status) {
      case DeliveryStatus.readyForPickup:
        return 'ຮັບ Order';
      case DeliveryStatus.pickedUp:
        return 'ເລີ່ມສົ່ງ';
      case DeliveryStatus.delivering:
        return 'ສົ່ງສຳເລັດ';
      default:
        return '';
    }
  }

  /// Get formatted price
  String get formattedTotal => '${_formatNumber(total)} ₭';
  String get formattedDeliveryFee => '${_formatNumber(deliveryFee)} ₭';

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
