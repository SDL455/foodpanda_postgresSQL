// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      body: json['body'] as String,
      image: json['image'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      orderId: json['orderId'] as String?,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'image': instance.image,
      'data': instance.data,
      'orderId': instance.orderId,
      'isRead': instance.isRead,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.orderPlaced: 'ORDER_PLACED',
  NotificationType.orderConfirmed: 'ORDER_CONFIRMED',
  NotificationType.orderPreparing: 'ORDER_PREPARING',
  NotificationType.orderReady: 'ORDER_READY',
  NotificationType.orderPickedUp: 'ORDER_PICKED_UP',
  NotificationType.orderDelivering: 'ORDER_DELIVERING',
  NotificationType.orderDelivered: 'ORDER_DELIVERED',
  NotificationType.orderCancelled: 'ORDER_CANCELLED',
  NotificationType.newOrder: 'NEW_ORDER',
  NotificationType.newDelivery: 'NEW_DELIVERY',
  NotificationType.deliveryAssigned: 'DELIVERY_ASSIGNED',
  NotificationType.promotion: 'PROMOTION',
  NotificationType.chatMessage: 'CHAT_MESSAGE',
  NotificationType.system: 'SYSTEM',
};

NotificationListResponse _$NotificationListResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationListResponseToJson(
        NotificationListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };

UnreadCountResponse _$UnreadCountResponseFromJson(Map<String, dynamic> json) =>
    UnreadCountResponse(
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$UnreadCountResponseToJson(
        UnreadCountResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
    };

