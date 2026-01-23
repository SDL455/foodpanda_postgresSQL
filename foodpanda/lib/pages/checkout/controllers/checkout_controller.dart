import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';
import '../../../routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  // Cart controller reference
  late CartController cartController;

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isPlacingOrder = false.obs;
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rxn<AddressModel> selectedAddress = Rxn<AddressModel>();

  // Payment methods
  final RxList<PaymentMethod> paymentMethods = <PaymentMethod>[
    PaymentMethod(
      id: 'cash',
      name: 'ເງິນສົດ',
      icon: Icons.money,
      description: 'ຈ່າຍເງິນສົດເມື່ອຮັບອາຫານ',
    ),
    PaymentMethod(
      id: 'bcel',
      name: 'BCEL One',
      icon: Icons.account_balance,
      description: 'ຊຳລະຜ່ານ BCEL One',
    ),
    PaymentMethod(
      id: 'ldb',
      name: 'LDB',
      icon: Icons.account_balance_wallet,
      description: 'ຊຳລະຜ່ານ LDB Mobile',
    ),
  ].obs;
  final RxString selectedPaymentMethod = 'cash'.obs;

  // Note controller
  final noteController = TextEditingController();

  // Getters from cart
  List<CartItemModel> get cartItems => cartController.cartItems;
  RestaurantModel? get restaurant => cartController.currentRestaurant.value;
  double get subtotal => cartController.subtotal;
  double get deliveryFee => cartController.deliveryFee;
  double get total => cartController.total;
  int get itemCount => cartController.itemCount;

  @override
  void onInit() {
    super.onInit();
    // Get cart controller
    cartController = Get.find<CartController>();
    loadAddresses();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      final data = await _profileRepository.getAddresses();
      addresses.value = data;

      // Select default address
      if (addresses.isNotEmpty) {
        final defaultAddress = addresses.firstWhereOrNull((a) => a.isDefault);
        selectedAddress.value = defaultAddress ?? addresses.first;
      }
    } catch (e) {
      LoggerService.error('Failed to load addresses', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດໂຫຼດທີ່ຢູ່ໄດ້',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
    Get.back();
  }

  void selectPaymentMethod(String methodId) {
    selectedPaymentMethod.value = methodId;
  }

  PaymentMethod? get currentPaymentMethod {
    return paymentMethods.firstWhereOrNull(
      (m) => m.id == selectedPaymentMethod.value,
    );
  }

  bool get canPlaceOrder {
    return selectedAddress.value != null &&
        cartItems.isNotEmpty &&
        restaurant != null;
  }

  Future<void> placeOrder() async {
    // Validation
    if (selectedAddress.value == null) {
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ກະລຸນາເລືອກທີ່ຢູ່ສົ່ງ',
        isError: true,
      );
      return;
    }

    if (cartItems.isEmpty) {
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ກະຕ່າຫວ່າງເປົ່າ',
        isError: true,
      );
      return;
    }

    if (restaurant == null) {
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ພົບຂໍ້ມູນຮ້ານ',
        isError: true,
      );
      return;
    }

    try {
      isPlacingOrder.value = true;

      final order = await _orderRepository.createOrder(
        restaurantId: restaurant!.id,
        items: cartItems,
        deliveryAddress: selectedAddress.value!.address,
        deliveryLatitude: selectedAddress.value!.latitude,
        deliveryLongitude: selectedAddress.value!.longitude,
        note: noteController.text.trim().isNotEmpty
            ? noteController.text.trim()
            : null,
        paymentMethod: selectedPaymentMethod.value,
      );

      // Clear cart after successful order
      cartController.clearCart();

      // Show success message
      Helpers.showSnackbar(title: 'ສຳເລັດ', message: 'ສັ່ງອາຫານສຳເລັດແລ້ວ');

      // Navigate to order tracking or confirmation
      Get.offAllNamed(AppRoutes.main);
      Get.toNamed(AppRoutes.orders, arguments: {'orderId': order.id});
    } catch (e) {
      LoggerService.error('Failed to place order', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: e.toString(),
        isError: true,
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final String description;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}
