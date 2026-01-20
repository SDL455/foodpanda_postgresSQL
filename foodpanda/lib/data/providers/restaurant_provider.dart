import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';

class RestaurantProvider {
  final ApiClient _apiClient = ApiClient();

  /// ດຶງລາຍການຮ້ານທັງໝົດ
  /// Response: { success, data: { stores, pagination } }
  Future<Map<String, dynamic>> getStores({
    int page = 1,
    int limit = 20,
    String? search,
    double? lat,
    double? lng,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (lat != null) queryParams['lat'] = lat;
      if (lng != null) queryParams['lng'] = lng;
      
      final response = await _apiClient.get(
        ApiConstants.stores,
        queryParameters: queryParams,
      );
      
      // Response format: { success: true, data: { stores: [], pagination: {} } }
      final data = response.data['data'] ?? response.data;
      return {
        'stores': data['stores'] ?? [],
        'pagination': data['pagination'] ?? {},
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ດຶງລາຍລະອຽດຮ້ານ ພ້ອມ categories ແລະ products
  /// Response: { success, data: { store with categories, products, reviews } }
  Future<Map<String, dynamic>> getStoreById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.storeDetail}$id');
      
      // Response format: { success: true, data: { ...store } }
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ດຶງຮ້ານຍອດນິຍົມ (sorted by rating)
  Future<List<dynamic>> getPopularStores({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.stores,
        queryParameters: {
          'limit': limit,
        },
      );
      
      final data = response.data['data'] ?? response.data;
      return data['stores'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ດຶງຮ້ານໃກ້ຄຽງ (ອີງຕາມ lat/lng)
  Future<List<dynamic>> getNearbyStores({
    required double latitude,
    required double longitude,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.stores,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'limit': limit,
        },
      );
      
      final data = response.data['data'] ?? response.data;
      return data['stores'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ຄົ້ນຫາຮ້ານ
  Future<Map<String, dynamic>> searchStores({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.stores,
        queryParameters: {
          'search': query,
          'page': page,
          'limit': limit,
        },
      );
      
      final data = response.data['data'] ?? response.data;
      return {
        'stores': data['stores'] ?? [],
        'pagination': data['pagination'] ?? {},
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ດຶງ categories ຂອງຮ້ານ (ຈາກ store detail)
  Future<List<dynamic>> getCategoriesByStore(String storeId) async {
    try {
      final storeData = await getStoreById(storeId);
      return storeData['categories'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ດຶງ products/menu ຂອງຮ້ານ (ຈາກ store detail)
  Future<List<dynamic>> getProductsByStore(String storeId) async {
    try {
      final storeData = await getStoreById(storeId);
      final categories = storeData['categories'] as List? ?? [];
      
      // Flatten all products from all categories
      final products = <dynamic>[];
      for (final category in categories) {
        final categoryProducts = category['products'] as List? ?? [];
        for (final product in categoryProducts) {
          products.add({
            ...product,
            'categoryName': category['name'],
            'categoryId': category['id'],
          });
        }
      }
      
      return products;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ດຶງລີວິວຂອງຮ້ານ (ຈາກ store detail)
  Future<List<dynamic>> getReviewsByStore(String storeId) async {
    try {
      final storeData = await getStoreById(storeId);
      return storeData['reviews'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // =====================================
  // Legacy methods for backward compatibility
  // =====================================
  
  @Deprecated('Use getStores() instead')
  Future<List<dynamic>> getRestaurants({int page = 1, int limit = 20}) async {
    final result = await getStores(page: page, limit: limit);
    return result['stores'] ?? [];
  }

  @Deprecated('Use getStoreById() instead')
  Future<Map<String, dynamic>> getRestaurantById(String id) async {
    return getStoreById(id);
  }

  @Deprecated('Use getPopularStores() instead')
  Future<List<dynamic>> getPopularRestaurants() async {
    return getPopularStores();
  }

  @Deprecated('Use getNearbyStores() instead')
  Future<List<dynamic>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radius = 5000,
  }) async {
    return getNearbyStores(latitude: latitude, longitude: longitude);
  }

  @Deprecated('Use searchStores() instead')
  Future<List<dynamic>> searchRestaurants({
    required String query,
    String? categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await searchStores(query: query, page: page, limit: limit);
    return result['stores'] ?? [];
  }

  @Deprecated('Use getCategoriesByStore() instead')
  Future<List<dynamic>> getCategories() async {
    return [];
  }

  @Deprecated('Use getProductsByStore() instead')
  Future<List<dynamic>> getMenuByRestaurant(String restaurantId) async {
    return getProductsByStore(restaurantId);
  }
}
