import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';

class RestaurantProvider {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getRestaurants({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.restaurants,
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

  Future<Map<String, dynamic>> getRestaurantById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.restaurantDetail}$id');
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<dynamic>> getPopularRestaurants() async {
    try {
      final response = await _apiClient.get(ApiConstants.popularRestaurants);
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<dynamic>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radius = 5000, // meters
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.nearbyRestaurants,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<dynamic>> searchRestaurants({
    required String query,
    String? categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.searchRestaurants,
        queryParameters: {
          'q': query,
          if (categoryId != null) 'category_id': categoryId,
          'page': page,
          'limit': limit,
        },
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.categories);
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<dynamic>> getMenuByRestaurant(String restaurantId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.menuByRestaurant}$restaurantId/menu',
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
