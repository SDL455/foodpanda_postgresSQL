import '../models/restaurant_model.dart';
import '../models/menu_item_model.dart';
import '../models/category_model.dart';
import '../providers/restaurant_provider.dart';

class RestaurantRepository {
  final RestaurantProvider _provider = RestaurantProvider();

  /// ດຶງລາຍການຮ້ານທັງໝົດ ພ້ອມ pagination
  Future<({List<RestaurantModel> stores, Map<String, dynamic> pagination})>
  getStores({
    int page = 1,
    int limit = 20,
    String? search,
    double? lat,
    double? lng,
  }) async {
    final result = await _provider.getStores(
      page: page,
      limit: limit,
      search: search,
      lat: lat,
      lng: lng,
    );

    final stores = (result['stores'] as List)
        .map((e) => RestaurantModel.fromJson(e))
        .toList();

    return (
      stores: stores,
      pagination: result['pagination'] as Map<String, dynamic>,
    );
  }

  /// ດຶງລາຍລະອຽດຮ້ານ ພ້ອມ categories ແລະ products
  Future<RestaurantModel> getStoreById(String id) async {
    final data = await _provider.getStoreById(id);
    return RestaurantModel.fromJson(data);
  }

  /// ດຶງຮ້ານຍອດນິຍົມ
  Future<List<RestaurantModel>> getPopularStores({int limit = 10}) async {
    final data = await _provider.getPopularStores(limit: limit);
    return data.map((e) => RestaurantModel.fromJson(e)).toList();
  }

  /// ດຶງຮ້ານໃກ້ຄຽງ
  Future<List<RestaurantModel>> getNearbyStores({
    required double latitude,
    required double longitude,
    int limit = 20,
  }) async {
    final data = await _provider.getNearbyStores(
      latitude: latitude,
      longitude: longitude,
      limit: limit,
    );
    return data.map((e) => RestaurantModel.fromJson(e)).toList();
  }

  /// ຄົ້ນຫາຮ້ານ ພ້ອມ pagination
  Future<({dynamic pagination, List<RestaurantModel> stores})> searchStores({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _provider.searchStores(
      query: query,
      page: page,
      limit: limit,
    );

    final stores = (result['stores'] as List)
        .map((e) => RestaurantModel.fromJson(e))
        .toList();

    return (stores: stores, pagination: result['pagination'] ?? {});
  }

  /// ດຶງ categories ຂອງຮ້ານ
  Future<List<CategoryModel>> getCategoriesByStore(String storeId) async {
    final data = await _provider.getCategoriesByStore(storeId);
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  /// ດຶງ products/menu ຂອງຮ້ານ
  Future<List<MenuItemModel>> getProductsByStore(String storeId) async {
    final data = await _provider.getProductsByStore(storeId);
    return data.map((e) => MenuItemModel.fromJson(e)).toList();
  }

  // =====================================
  // Legacy methods for backward compatibility
  // =====================================

  @Deprecated('Use getStores() instead')
  Future<List<RestaurantModel>> getRestaurants({
    int page = 1,
    int limit = 20,
  }) async {
    final result = await getStores(page: page, limit: limit);
    return result.stores;
  }

  @Deprecated('Use getStoreById() instead')
  Future<RestaurantModel> getRestaurantById(String id) async {
    return getStoreById(id);
  }

  @Deprecated('Use getPopularStores() instead')
  Future<List<RestaurantModel>> getPopularRestaurants() async {
    return getPopularStores();
  }

  @Deprecated('Use getNearbyStores() instead')
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radius = 5000,
  }) async {
    return getNearbyStores(latitude: latitude, longitude: longitude);
  }

  @Deprecated('Use searchStores() instead')
  Future<List<RestaurantModel>> searchRestaurants({
    required String query,
    String? categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await searchStores(query: query, page: page, limit: limit);
    return result.stores;
  }

  @Deprecated('Use getCategoriesByStore() instead')
  Future<List<CategoryModel>> getCategories() async {
    return [];
  }

  @Deprecated('Use getProductsByStore() instead')
  Future<List<MenuItemModel>> getMenuByRestaurant(String restaurantId) async {
    return getProductsByStore(restaurantId);
  }
}
