import 'package:get/get.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../core/utils/helpers.dart';

class CartController extends GetxController {
  // Observable states
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final Rxn<RestaurantModel> currentRestaurant = Rxn<RestaurantModel>();

  // Getters
  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryFee {
    return (currentRestaurant.value?.deliveryFee ?? 0).toDouble();
  }

  double get total {
    return subtotal + deliveryFee;
  }

  int get itemCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => cartItems.isEmpty;

  // Add item to cart
  void addToCart({
    required MenuItemModel menuItem,
    required RestaurantModel restaurant,
    int quantity = 1,
    List<SelectedOption>? selectedOptions,
    String? note,
  }) {
    // Check if cart has items from different restaurant
    if (currentRestaurant.value != null &&
        currentRestaurant.value!.id != restaurant.id) {
      _showChangeRestaurantDialog(
        restaurant: restaurant,
        menuItem: menuItem,
        quantity: quantity,
        selectedOptions: selectedOptions,
        note: note,
      );
      return;
    }

    currentRestaurant.value = restaurant;

    // Check if item already exists
    final existingIndex = cartItems.indexWhere(
      (item) =>
          item.menuItem.id == menuItem.id &&
          _compareOptions(item.selectedOptions, selectedOptions),
    );

    if (existingIndex != -1) {
      // Update quantity
      cartItems[existingIndex].quantity += quantity;
      cartItems.refresh();
    } else {
      // Add new item
      cartItems.add(
        CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          menuItem: menuItem,
          quantity: quantity,
          selectedOptions: selectedOptions,
          note: note,
        ),
      );
    }

    Helpers.showSnackbar(
      title: 'ເພີ່ມແລ້ວ',
      message: '${menuItem.name} ຖືກເພີ່ມໃສ່ກະຕ່າ',
    );
  }

  // Update item quantity
  void updateQuantity(String itemId, int quantity) {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (quantity <= 0) {
        removeItem(itemId);
      } else {
        cartItems[index].quantity = quantity;
        cartItems.refresh();
      }
    }
  }

  // Remove item
  void removeItem(String itemId) {
    cartItems.removeWhere((item) => item.id == itemId);
    if (cartItems.isEmpty) {
      currentRestaurant.value = null;
    }
  }

  // Clear cart
  void clearCart() {
    cartItems.clear();
    currentRestaurant.value = null;
  }

  // Compare options
  bool _compareOptions(
    List<SelectedOption>? options1,
    List<SelectedOption>? options2,
  ) {
    if (options1 == null && options2 == null) return true;
    if (options1 == null || options2 == null) return false;
    if (options1.length != options2.length) return false;

    for (var i = 0; i < options1.length; i++) {
      if (options1[i].optionId != options2[i].optionId) return false;
    }
    return true;
  }

  // Show change restaurant dialog
  Future<void> _showChangeRestaurantDialog({
    required RestaurantModel restaurant,
    required MenuItemModel menuItem,
    required int quantity,
    List<SelectedOption>? selectedOptions,
    String? note,
  }) async {
    final confirm = await Helpers.showConfirmDialog(
      title: 'ປ່ຽນຮ້ານອາຫານ?',
      message:
          'ກະຕ່າຂອງທ່ານມີສິນຄ້າຈາກຮ້ານ ${currentRestaurant.value?.name}. ທ່ານຕ້ອງການລຶບແລະເພີ່ມຈາກຮ້ານໃໝ່ບໍ?',
    );

    if (confirm) {
      clearCart();
      addToCart(
        menuItem: menuItem,
        restaurant: restaurant,
        quantity: quantity,
        selectedOptions: selectedOptions,
        note: note,
      );
    }
  }
}
