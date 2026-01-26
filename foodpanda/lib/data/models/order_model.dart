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
    // Handle both camelCase (from server) and snake_case formats
    final userId = json['customerId'] ?? json['user_id'] ?? '';
    final storeData = json['store'] ?? json['restaurant'];
    final statusStr = (json['status'] as String?)?.toUpperCase() ?? 'PENDING';

    // Map server status to OrderStatus enum
    OrderStatus orderStatus;
    switch (statusStr) {
      case 'PENDING':
        orderStatus = OrderStatus.pending;
        break;
      case 'CONFIRMED':
        orderStatus = OrderStatus.confirmed;
        break;
      case 'PREPARING':
        orderStatus = OrderStatus.preparing;
        break;
      case 'READY_FOR_PICKUP':
      case 'READY':
        orderStatus = OrderStatus.ready;
        break;
      case 'PICKED_UP':
      case 'DELIVERING':
      case 'ON_THE_WAY':
        orderStatus = OrderStatus.onTheWay;
        break;
      case 'DELIVERED':
        orderStatus = OrderStatus.delivered;
        break;
      case 'CANCELLED':
        orderStatus = OrderStatus.cancelled;
        break;
      default:
        orderStatus = OrderStatus.pending;
    }

    // Parse items - transform server format to CartItemModel format
    List<dynamic> itemsList = [];
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List).map((item) {
        if (item is Map) {
          // If it's already in CartItemModel format, return as is
          if (item.containsKey('menu_item')) {
            return item;
          }
          // Transform server order item format to CartItemModel format
          final variants = item['variants'] as List? ?? [];
          final selectedOptions = <Map<String, dynamic>>[];

          // Group variants by option (if needed) or create a simple structure
          if (variants.isNotEmpty) {
            selectedOptions.add({
              'option_id': 'variants',
              'option_name': 'Variants',
              'selected_items': variants
                  .map<Map<String, dynamic>>(
                    (v) => {
                      'id': v['variantId'] ?? v['variant_id'],
                      'name': v['variantName'] ?? v['variant_name'],
                      'price':
                          ((v['priceDelta'] ?? v['price_delta'] ?? 0) as num)
                              .toDouble(),
                    },
                  )
                  .toList(),
            });
          }

          return {
            'id': item['id'] ?? item['productId'] ?? '',
            'menu_item': {
              'id': item['productId'] ?? item['product_id'] ?? '',
              'name': item['productName'] ?? item['product_name'] ?? '',
              'image': item['productImage'] ?? item['product_image'],
              'price': ((item['unitPrice'] ?? item['unit_price'] ?? 0) as num)
                  .toDouble(),
            },
            'quantity': item['quantity'] ?? 1,
            'selected_options': selectedOptions,
            'note': item['note'],
          };
        }
        return item;
      }).toList();
    }

    // Parse dates - handle both formats
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return OrderModel(
      id: json['id'] ?? '',
      userId: userId,
      restaurant: RestaurantModel.fromJson(storeData ?? {}),
      items: itemsList
          .map(
            (e) => CartItemModel.fromJson(
              e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{},
            ),
          )
          .toList(),
      subtotal: ((json['subtotal'] ?? 0) as num).toDouble(),
      deliveryFee: ((json['deliveryFee'] ?? json['delivery_fee'] ?? 0) as num)
          .toDouble(),
      discount: ((json['discount'] ?? 0) as num).toDouble(),
      total: ((json['total'] ?? 0) as num).toDouble(),
      status: orderStatus,
      deliveryAddress:
          json['deliveryAddress'] ?? json['delivery_address'] ?? '',
      deliveryLatitude: (json['deliveryLat'] ?? json['delivery_latitude'])
          ?.toDouble(),
      deliveryLongitude: (json['deliveryLng'] ?? json['delivery_longitude'])
          ?.toDouble(),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'],
      isPaid: json['paymentStatus'] == 'PAID' || json['is_paid'] == true,
      note: json['deliveryNote'] ?? json['note'],
      driverName:
          json['delivery']?['rider']?['fullName'] ?? json['driver_name'],
      driverPhone: json['delivery']?['rider']?['phone'] ?? json['driver_phone'],
      driverLatitude:
          json['delivery']?['rider']?['currentLat']?.toDouble() ??
          json['driver_latitude']?.toDouble(),
      driverLongitude:
          json['delivery']?['rider']?['currentLng']?.toDouble() ??
          json['driver_longitude']?.toDouble(),
      createdAt:
          parseDate(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      estimatedDelivery: parseDate(
        json['estimatedDelivery'] ?? json['estimated_delivery'],
      ),
      deliveredAt: parseDate(json['deliveredAt'] ?? json['delivered_at']),
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
