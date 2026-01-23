import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';

class OrderProvider {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> createOrder({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required double deliveryLatitude,
    required double deliveryLongitude,
    String? note,
    String? paymentMethod,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.createOrder,
        data: {
          'restaurant_id': restaurantId,
          'items': items,
          'delivery_address': deliveryAddress,
          'delivery_latitude': deliveryLatitude,
          'delivery_longitude': deliveryLongitude,
          'note': note,
          'payment_method': paymentMethod,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<dynamic>> getOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.orders,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<dynamic>> getActiveOrders() async {
    try {
      final response = await _apiClient.get(ApiConstants.activeOrders);
      final data = response.data;
      if (data is Map && data['data'] != null) {
        return data['data'] as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<dynamic>> getOrderHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.orderHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data;
      if (data is Map && data['data'] != null) {
        return data['data'] as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.orderDetail}$id');
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> trackOrder(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.trackOrder}$id');
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> cancelOrder(String id, {String? reason}) async {
    try {
      await _apiClient.post(
        ApiConstants.cancelOrder,
        data: {
          'order_id': id,
          'reason': reason,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
