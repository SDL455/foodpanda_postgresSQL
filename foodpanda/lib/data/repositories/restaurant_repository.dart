import '../models/restaurant_model.dart';
import '../models/menu_item_model.dart';
import '../models/category_model.dart';
import '../providers/restaurant_provider.dart';

class RestaurantRepository {
  final RestaurantProvider _provider = RestaurantProvider();

  Future<List<RestaurantModel>> getRestaurants({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _provider.getRestaurants(page: page, limit: limit);
    return data.map((e) => RestaurantModel.fromJson(e)).toList();
  }

  Future<RestaurantModel> getRestaurantById(String id) async {
    final data = await _provider.getRestaurantById(id);
    return RestaurantModel.fromJson(data);
  }

  Future<List<RestaurantModel>> getPopularRestaurants() async {
    final data = await _provider.getPopularRestaurants();
    return data.map((e) => RestaurantModel.fromJson(e)).toList();
  }

  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radius = 5000,
  }) async {
    final data = await _provider.getNearbyRestaurants(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
    return data.map((e) => RestaurantModel.fromJson(e)).toList();
  }

  Future<List<RestaurantModel>> searchRestaurants({
    required String query,
    String? categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _provider.searchRestaurants(
      query: query,
      categoryId: categoryId,
      page: page,
      limit: limit,
    );
    return data.map((e) => RestaurantModel.fromJson(e)).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final data = await _provider.getCategories();
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<List<MenuItemModel>> getMenuByRestaurant(String restaurantId) async {
    final data = await _provider.getMenuByRestaurant(restaurantId);
    return data.map((e) => MenuItemModel.fromJson(e)).toList();
  }
}
