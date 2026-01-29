import 'package:get/get.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';

class RestaurantsController extends GetxController {
  final RestaurantRepository _repository = RestaurantRepository();

  // Observable states
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final int limit = 20;

  // Search
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRestaurants();
  }

  Future<void> loadRestaurants({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }

    if (!hasMore.value && !refresh) return;

    try {
      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final result = await _repository.getStores(
        page: currentPage.value,
        limit: limit,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (refresh || currentPage.value == 1) {
        restaurants.value = result.stores;
      } else {
        restaurants.addAll(result.stores);
      }

      // Check if there's more data
      final pagination = result.pagination;
      final totalPages = pagination['totalPages'] ?? 1;
      hasMore.value = currentPage.value < totalPages;

      if (hasMore.value) {
        currentPage.value++;
      }
    } catch (e) {
      LoggerService.error('Load restaurants error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນຮ້ານໄດ້',
        isError: true,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshRestaurants() async {
    await loadRestaurants(refresh: true);
  }

  void loadMore() {
    if (!isLoadingMore.value && hasMore.value) {
      loadRestaurants();
    }
  }

  void search(String query) {
    searchQuery.value = query;
    loadRestaurants(refresh: true);
  }

  void clearSearch() {
    searchQuery.value = '';
    loadRestaurants(refresh: true);
  }
}
