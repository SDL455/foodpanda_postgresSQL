import 'package:get/get.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';

class RestaurantDetailController extends GetxController {
  final RestaurantRepository _repository = RestaurantRepository();

  // Observable states
  final Rxn<RestaurantModel> restaurant = Rxn<RestaurantModel>();
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<FoodModel> foods = <FoodModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isFavoriteLoading = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;

  // Get restaurant from arguments or load from API
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RestaurantModel) {
      restaurant.value = args;
      isFavorite.value = args.isFavorite;
      _loadRestaurantDetail(args.id);
    } else if (args is String) {
      _loadRestaurantDetail(args);
    }
  }

  Future<void> _loadRestaurantDetail(String id) async {
    try {
      isLoading.value = true;

      // Load restaurant detail
      final result = await _repository.getStoreById(id);
      restaurant.value = result;
      isFavorite.value = result.isFavorite;

      // Load categories
      final categoryResult = await _repository.getCategoriesByStore(id);
      categories.value = categoryResult;

      // Load all foods for this restaurant
      final foodResult = await _repository.getFoods(storeId: id, limit: 100);
      foods.value = foodResult.foods;
    } catch (e) {
      LoggerService.error('Load restaurant detail error', e);
      if (restaurant.value == null) {
        Helpers.showSnackbar(
          title: 'ເກີດຂໍ້ຜິດພາດ',
          message: 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນຮ້ານໄດ້',
          isError: true,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    if (restaurant.value != null) {
      await _loadRestaurantDetail(restaurant.value!.id);
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    if (restaurant.value == null) return;

    try {
      isFavoriteLoading.value = true;
      final newStatus = !isFavorite.value;

      // TODO: Call API to save favorite status
      // await _repository.toggleStoreFavorite(restaurant.value!.id, newStatus);

      isFavorite.value = newStatus;
      restaurant.value = restaurant.value!.copyWith(isFavorite: newStatus);

      Helpers.showSnackbar(
        title: newStatus ? 'ບັນທຶກແລ້ວ' : 'ລຶບອອກແລ້ວ',
        message: newStatus
            ? 'ເພີ່ມ ${restaurant.value!.name} ໃສ່ລາຍການໂປດແລ້ວ'
            : 'ລຶບ ${restaurant.value!.name} ອອກຈາກລາຍການໂປດແລ້ວ',
      );
    } catch (e) {
      LoggerService.error('Toggle favorite error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດບັນທຶກລາຍການໂປດໄດ້',
        isError: true,
      );
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  /// Select category
  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  /// Get foods by selected category
  List<FoodModel> get filteredFoods {
    if (categories.isEmpty || selectedCategoryIndex.value == 0) {
      return foods;
    }

    final selectedCategory = categories[selectedCategoryIndex.value - 1];
    return foods
        .where((food) => food.category?.id == selectedCategory.id)
        .toList();
  }

  /// Get all categories with "All" option
  List<String> get categoryNames {
    return ['ທັງໝົດ', ...categories.map((c) => c.name)];
  }
}
