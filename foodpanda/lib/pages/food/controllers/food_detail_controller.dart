import 'package:get/get.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';
import '../../cart/controllers/cart_controller.dart';

class FoodDetailController extends GetxController {
  final RestaurantRepository _repository = RestaurantRepository();

  // Observable states
  final Rxn<FoodModel> food = Rxn<FoodModel>();
  final RxBool isLoading = false.obs;
  final RxInt quantity = 1.obs;
  final RxList<String> selectedVariantIds = <String>[].obs;
  final RxBool isFavorite = false.obs;
  final RxBool isFavoriteLoading = false.obs;

  // Get food from arguments or load from API
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is FoodModel) {
      food.value = args;
      isFavorite.value = args.isFavorite;
      _loadFoodDetail(args.id);
    } else if (args is String) {
      _loadFoodDetail(args);
    }
  }

  Future<void> _loadFoodDetail(String id) async {
    try {
      isLoading.value = true;
      final result = await _repository.getFoodById(id);
      food.value = result;
      isFavorite.value = result.isFavorite;
    } catch (e) {
      LoggerService.error('Load food detail error', e);
      if (food.value == null) {
        Helpers.showSnackbar(
          title: 'ເກີດຂໍ້ຜິດພາດ',
          message: 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນອາຫານໄດ້',
          isError: true,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle bookmark/favorite status
  Future<void> toggleFavorite() async {
    if (food.value == null) return;

    try {
      isFavoriteLoading.value = true;
      final newStatus = !isFavorite.value;

      // TODO: Call API to save favorite status
      // await _repository.toggleFoodFavorite(food.value!.id, newStatus);

      isFavorite.value = newStatus;
      food.value = food.value!.copyWith(isFavorite: newStatus);

      Helpers.showSnackbar(
        title: newStatus ? 'ບັນທຶກແລ້ວ' : 'ລຶບອອກແລ້ວ',
        message: newStatus
            ? 'ເພີ່ມ ${food.value!.name} ໃສ່ລາຍການໂປດແລ້ວ'
            : 'ລຶບ ${food.value!.name} ອອກຈາກລາຍການໂປດແລ້ວ',
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

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void toggleVariant(String variantId) {
    if (selectedVariantIds.contains(variantId)) {
      selectedVariantIds.remove(variantId);
    } else {
      selectedVariantIds.add(variantId);
    }
  }

  bool isVariantSelected(String variantId) {
    return selectedVariantIds.contains(variantId);
  }

  /// ຄິດໄລ່ລາຄາລວມ
  int get totalPrice {
    if (food.value == null) return 0;

    int basePrice = food.value!.price;
    int variantPrice = 0;

    for (final variantId in selectedVariantIds) {
      final variant = food.value!.variants.firstWhereOrNull(
        (v) => v.id == variantId,
      );
      if (variant != null) {
        variantPrice += variant.priceDelta;
      }
    }

    return (basePrice + variantPrice) * quantity.value;
  }

  /// ລາຄາລວມທີ່ສະແດງ
  String get totalPriceText {
    return '${_formatNumber(totalPrice)} ${food.value?.currency ?? 'LAK'}';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> addToCart() async {
    if (food.value == null) return;

    try {
      // Get CartController
      final cartController = Get.find<CartController>();

      // Convert FoodModel to MenuItemModel
      final menuItem = _convertToMenuItem(food.value!);

      // Convert FoodStore to RestaurantModel
      final restaurant = _convertToRestaurant(food.value!.store);

      // Convert selected variants to SelectedOptions
      final selectedOptions = _getSelectedOptions();

      // Add to cart
      cartController.addToCart(
        menuItem: menuItem,
        restaurant: restaurant,
        quantity: quantity.value,
        selectedOptions: selectedOptions.isNotEmpty ? selectedOptions : null,
      );

      // ແຈ້ງເຕືອນເພີ່ມໃສ່ກະຕ່າສຳເລັດ
      Helpers.showSnackbar(
        title: AppStrings.success,
        message: '${food.value!.name} ${AppStrings.addToCartSuccess}',
      );

      Get.back();
    } catch (e) {
      LoggerService.error('Add to cart error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດເພີ່ມໃສ່ກະຕ່າໄດ້',
        isError: true,
      );
    }
  }

  /// Convert FoodModel to MenuItemModel
  MenuItemModel _convertToMenuItem(FoodModel foodItem) {
    return MenuItemModel(
      id: foodItem.id,
      restaurantId: foodItem.store.id,
      name: foodItem.name,
      description: foodItem.description,
      image: foodItem.image,
      price: foodItem.price.toDouble(),
      isAvailable: foodItem.isAvailable,
    );
  }

  /// Convert FoodStore to RestaurantModel
  RestaurantModel _convertToRestaurant(FoodStore store) {
    return RestaurantModel(
      id: store.id,
      name: store.name,
      logo: store.logo,
      coverImage: store.coverImage,
      rating: store.rating,
      deliveryFee: store.deliveryFee,
      estimatedPrepTime: store.estimatedPrepTime,
      minOrderAmount: store.minOrderAmount ?? 0,
      address: store.address,
      openTime: store.openTime,
      closeTime: store.closeTime,
    );
  }

  /// Get selected options from selected variants
  List<SelectedOption> _getSelectedOptions() {
    if (food.value == null || selectedVariantIds.isEmpty) {
      return [];
    }

    final List<SelectedOption> options = [];

    for (final variantId in selectedVariantIds) {
      final variant = food.value!.variants.firstWhereOrNull(
        (v) => v.id == variantId,
      );
      if (variant != null) {
        options.add(
          SelectedOption(
            optionId: variant.id,
            optionName: variant.name,
            selectedItems: [
              OptionItem(
                id: variant.id,
                name: variant.name,
                price: variant.priceDelta.toDouble(),
              ),
            ],
          ),
        );
      }
    }

    return options;
  }
}
