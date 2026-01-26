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
    String? addressId,
  }) async {
    try {
      // Convert payment method to server format
      String serverPaymentMethod = 'CASH';
      switch (paymentMethod) {
        case 'cash':
          serverPaymentMethod = 'CASH';
          break;
        case 'bcel':
        case 'ldb':
          serverPaymentMethod = 'BANK_TRANSFER';
          break;
        default:
          serverPaymentMethod = 'CASH';
      }

      // Convert items to server format
      final serverItems = items.map((item) {
        final menuItem = item['menu_item'] as Map<String, dynamic>?;
        final selectedOptions = item['selected_options'] as List<dynamic>?;
        
        // Extract variant IDs from selected options
        List<String> variantIds = [];
        if (selectedOptions != null) {
          for (var option in selectedOptions) {
            final selectedItems = option['selected_items'] as List<dynamic>?;
            if (selectedItems != null) {
              for (var selectedItem in selectedItems) {
                if (selectedItem['id'] != null) {
                  variantIds.add(selectedItem['id'].toString());
                }
              }
            }
          }
        }
        
        return {
          'productId': menuItem?['id'] ?? item['id'],
          'quantity': item['quantity'] ?? 1,
          'note': item['note'],
          'variantIds': variantIds,
        };
      }).toList();

      final response = await _apiClient.post(
        ApiConstants.createOrder,
        data: {
          'storeId': restaurantId,
          'addressId': addressId,
          'items': serverItems,
          'deliveryAddress': deliveryAddress,
          'deliveryLat': deliveryLatitude,
          'deliveryLng': deliveryLongitude,
          'deliveryNote': note,
          'paymentMethod': serverPaymentMethod,
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
