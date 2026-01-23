import 'package:get/get.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';

class OrderHistoryController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxList<OrderModel> activeOrders = <OrderModel>[].obs;
  final RxList<OrderModel> orderHistory = <OrderModel>[].obs;
  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;

      // Load active orders - if error, just set empty list
      try {
        final active = await _orderRepository.getActiveOrders();
        activeOrders.value = active;
      } catch (e) {
        LoggerService.error('Load active orders error', e);
        activeOrders.value = [];
      }

      // Load order history - if error, just set empty list
      try {
        final history = await _orderRepository.getOrderHistory();
        orderHistory.value = history;
      } catch (e) {
        LoggerService.error('Load order history error', e);
        orderHistory.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders();
  }

  Future<void> getOrderDetail(String orderId) async {
    try {
      Helpers.showLoading();
      final order = await _orderRepository.getOrderById(orderId);
      selectedOrder.value = order;
      Helpers.hideLoading();
    } catch (e) {
      Helpers.hideLoading();
      LoggerService.error('Get order detail error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນຄຳສັ່ງຊື້ໄດ້',
        isError: true,
      );
    }
  }

  Future<void> trackOrder(String orderId) async {
    try {
      final order = await _orderRepository.trackOrder(orderId);
      selectedOrder.value = order;
    } catch (e) {
      LoggerService.error('Track order error', e);
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final confirm = await Helpers.showConfirmDialog(
        title: 'ຍົກເລີກຄຳສັ່ງຊື້',
        message: 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການຍົກເລີກຄຳສັ່ງຊື້ນີ້?',
      );

      if (!confirm) return;

      Helpers.showLoading(message: 'ກຳລັງຍົກເລີກ...');

      await _orderRepository.cancelOrder(orderId);
      await loadOrders();

      Helpers.hideLoading();
      Helpers.showSnackbar(title: 'ສຳເລັດ', message: 'ຍົກເລີກຄຳສັ່ງຊື້ແລ້ວ');
    } catch (e) {
      Helpers.hideLoading();
      LoggerService.error('Cancel order error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດຍົກເລີກຄຳສັ່ງຊື້ໄດ້',
        isError: true,
      );
    }
  }

  Future<void> reorder(OrderModel order) async {
    try {
      Helpers.showLoading(message: 'ກຳລັງເພີ່ມໃສ່ກະຕ່າ...');
      // TODO: Implement reorder logic - add items to cart
      Helpers.hideLoading();
      Helpers.showSnackbar(
        title: 'ສຳເລັດ',
        message: 'ເພີ່ມລາຍການໃສ່ກະຕ່າແລ້ວ',
      );
    } catch (e) {
      Helpers.hideLoading();
      LoggerService.error('Reorder error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດສັ່ງອີກຄັ້ງໄດ້',
        isError: true,
      );
    }
  }
}
