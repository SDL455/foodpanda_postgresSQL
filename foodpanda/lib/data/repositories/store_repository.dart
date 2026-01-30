import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class StoreRepository {
  final ApiClient _apiClient = ApiClient();

  /// Store Login
  Future<Map<String, dynamic>> loginStore({
    required String storeId,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.baseUrl}/api/auth/store/login',
      data: {
        'storeId': storeId,
        'password': password,
      },
    );

    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception(response.data['message'] ?? 'Failed to login');
  }

  /// Get Store Orders
  Future<Map<String, dynamic>> getOrders({
    String type = 'pending',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.baseUrl}/api/mobile/store/orders?type=$type&page=$page&limit=$limit',
    );

    if (response.data['success'] == true) {
      return {
        'orders': response.data['data'] ?? [],
        'meta': response.data['meta'] ?? {},
      };
    }
    throw Exception(response.data['message'] ?? 'Failed to get orders');
  }

  /// Get Order Detail
  Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    final response = await _apiClient.get(
      '${ApiConstants.baseUrl}/api/mobile/store/orders/$orderId',
    );

    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception(response.data['message'] ?? 'Failed to get order detail');
  }

  /// Update Order Status
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
    String? cancelReason,
  }) async {
    final response = await _apiClient.patch(
      '${ApiConstants.baseUrl}/api/mobile/store/orders/$orderId/status',
      data: {
        'status': status,
        if (cancelReason != null) 'cancelReason': cancelReason,
      },
    );

    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception(response.data['message'] ?? 'Failed to update order status');
  }
}
