import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// Notification types matching backend enum
enum NotificationType {
  @JsonValue('ORDER_PLACED')
  orderPlaced,
  @JsonValue('ORDER_CONFIRMED')
  orderConfirmed,
  @JsonValue('ORDER_PREPARING')
  orderPreparing,
  @JsonValue('ORDER_READY')
  orderReady,
  @JsonValue('ORDER_PICKED_UP')
  orderPickedUp,
  @JsonValue('ORDER_DELIVERING')
  orderDelivering,
  @JsonValue('ORDER_DELIVERED')
  orderDelivered,
  @JsonValue('ORDER_CANCELLED')
  orderCancelled,
  @JsonValue('NEW_ORDER')
  newOrder,
  @JsonValue('NEW_DELIVERY')
  newDelivery,
  @JsonValue('DELIVERY_ASSIGNED')
  deliveryAssigned,
  @JsonValue('PROMOTION')
  promotion,
  @JsonValue('CHAT_MESSAGE')
  chatMessage,
  @JsonValue('SYSTEM')
  system,
}

@JsonSerializable()
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? image;
  final Map<String, dynamic>? data;
  final String? orderId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.image,
    this.data,
    this.orderId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? image,
    Map<String, dynamic>? data,
    String? orderId,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      image: image ?? this.image,
      data: data ?? this.data,
      orderId: orderId ?? this.orderId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@JsonSerializable()
class NotificationListResponse {
  final List<NotificationModel> data;
  final PaginationMeta meta;

  NotificationListResponse({
    required this.data,
    required this.meta,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListResponseToJson(this);
}

@JsonSerializable()
class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}

@JsonSerializable()
class UnreadCountResponse {
  final int count;

  UnreadCountResponse({required this.count});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountResponseToJson(this);
}

