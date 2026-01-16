import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../providers/order_provider.dart';

class OrderRepository {
  final OrderProvider _provider = OrderProvider();

  Future<OrderModel> createOrder({
    required String restaurantId,
    required List<CartItemModel> items,
    required String deliveryAddress,
    required double deliveryLatitude,
    required double deliveryLongitude,
    String? note,
    String? paymentMethod,
  }) async {
    final itemsData = items.map((e) => e.toJson()).toList();

    final data = await _provider.createOrder(
      restaurantId: restaurantId,
      items: itemsData,
      deliveryAddress: deliveryAddress,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      note: note,
      paymentMethod: paymentMethod,
    );

    return OrderModel.fromJson(data);
  }

  Future<List<OrderModel>> getOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _provider.getOrders(page: page, limit: limit);
    return data.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<List<OrderModel>> getActiveOrders() async {
    final data = await _provider.getActiveOrders();
    return data.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<List<OrderModel>> getOrderHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _provider.getOrderHistory(page: page, limit: limit);
    return data.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> getOrderById(String id) async {
    final data = await _provider.getOrderById(id);
    return OrderModel.fromJson(data);
  }

  Future<OrderModel> trackOrder(String id) async {
    final data = await _provider.trackOrder(id);
    return OrderModel.fromJson(data);
  }

  Future<void> cancelOrder(String id, {String? reason}) async {
    await _provider.cancelOrder(id, reason: reason);
  }
}
