/// Notification types
enum NotificationType {
  orderPlaced,
  orderConfirmed,
  orderPreparing,
  orderReady,
  orderPickedUp,
  orderDelivering,
  orderDelivered,
  orderCancelled,
  newOrder,
  newDelivery,
  deliveryAssigned,
  promotion,
  chatMessage,
  system,
}

class NotificationModel {
  final String id;
  final String? userId;
  final String? customerId;
  final String? riderId;
  final String title;
  final String body;
  final String? type; // order, promotion, system
  final String? referenceId; // orderId, promotionId, etc.
  final String? orderId;
  final String? image;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final bool isSent;
  final DateTime? sentAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    this.userId,
    this.customerId,
    this.riderId,
    required this.title,
    required this.body,
    this.type,
    this.referenceId,
    this.orderId,
    this.image,
    this.data,
    this.isRead = false,
    this.readAt,
    this.isSent = false,
    this.sentAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'],
      customerId: json['customerId'] ?? json['customer_id'],
      riderId: json['riderId'] ?? json['rider_id'],
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      type: json['type'],
      referenceId: json['referenceId'] ?? json['reference_id'],
      orderId: json['orderId'] ?? json['order_id'],
      image: json['image'],
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'])
          : (json['read_at'] != null ? DateTime.parse(json['read_at']) : null),
      isSent: json['isSent'] ?? json['is_sent'] ?? false,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'])
          : (json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'customerId': customerId,
      'riderId': riderId,
      'title': title,
      'body': body,
      'type': type,
      'referenceId': referenceId,
      'orderId': orderId,
      'image': image,
      'data': data,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'isSent': isSent,
      'sentAt': sentAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? customerId,
    String? riderId,
    String? title,
    String? body,
    String? type,
    String? referenceId,
    String? orderId,
    String? image,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? readAt,
    bool? isSent,
    DateTime? sentAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      riderId: riderId ?? this.riderId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      orderId: orderId ?? this.orderId,
      image: image ?? this.image,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if this is a new delivery notification for rider
  bool get isNewDelivery => type == 'NEW_DELIVERY';

  /// Check if this is a delivery assigned notification for rider
  bool get isDeliveryAssigned => type == 'DELIVERY_ASSIGNED';

  /// Check if this is an order-related notification
  bool get isOrderRelated =>
      type?.startsWith('ORDER_') == true ||
      type == 'NEW_DELIVERY' ||
      type == 'DELIVERY_ASSIGNED';
}
