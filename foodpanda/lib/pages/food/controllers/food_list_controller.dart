import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/food_model.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';

class FoodListController extends GetxController {
  final RestaurantRepository _repository = RestaurantRepository();

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Observable states
  final RxList<FoodModel> foods = <FoodModel>[].obs;
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
    loadFoods();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadFoods({bool refresh = false}) async {
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

      final result = await _repository.getFoods(
        page: currentPage.value,
        limit: limit,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (refresh || currentPage.value == 1) {
        foods.value = result.foods;
      } else {
        foods.addAll(result.foods);
      }

      // Check if there's more data
      final pagination = result.pagination;
      final totalPages = pagination['totalPages'] ?? 1;
      hasMore.value = currentPage.value < totalPages;

      if (hasMore.value) {
        currentPage.value++;
      }
    } catch (e) {
      LoggerService.error('Load foods error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນອາຫານໄດ້',
        isError: true,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshFoods() async {
    await loadFoods(refresh: true);
  }

  void loadMore() {
    if (!isLoadingMore.value && hasMore.value) {
      loadFoods();
    }
  }

  void search(String query) {
    searchQuery.value = query;
    loadFoods(refresh: true);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadFoods(refresh: true);
  }
}
