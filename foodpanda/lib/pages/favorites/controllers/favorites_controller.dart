import 'package:get/get.dart';
import '../../../data/models/favorite_model.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';
import '../../../routes/app_routes.dart';

class FavoritesController extends GetxController {
  final ProfileRepository _repository = ProfileRepository();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxList<FavoriteModel> favorites = <FavoriteModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      final data = await _repository.getFavorites();
      favorites.value = data.map((e) => FavoriteModel.fromJson(e)).toList();
    } catch (e) {
      LoggerService.error('Failed to load favorites', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດໂຫຼດຮ້ານໂປດໄດ້',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshFavorites() async {
    await loadFavorites();
  }

  Future<void> removeFromFavorites(String storeId) async {
    final confirm = await Helpers.showConfirmDialog(
      title: 'ເອົາອອກຈາກລາຍການໂປດ',
      message: 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການເອົາຮ້ານນີ້ອອກຈາກລາຍການໂປດ?',
    );

    if (!confirm) return;

    try {
      Helpers.showLoading(message: 'ກຳລັງເອົາອອກ...');
      await _repository.removeFromFavorites(storeId);
      favorites.removeWhere((f) => f.storeId == storeId);
      Helpers.hideLoading();
      Helpers.showSnackbar(title: 'ສຳເລັດ', message: 'ເອົາອອກຈາກລາຍການໂປດແລ້ວ');
    } catch (e) {
      Helpers.hideLoading();
      LoggerService.error('Failed to remove from favorites', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດເອົາອອກໄດ້',
        isError: true,
      );
    }
  }

  void goToRestaurant(RestaurantModel restaurant) {
    Get.toNamed(AppRoutes.restaurantDetail, arguments: restaurant);
  }
}
