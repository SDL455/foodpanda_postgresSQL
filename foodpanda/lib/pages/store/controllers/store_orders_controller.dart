import 'dart:ui';

import 'package:get/get.dart';
import '../../../data/repositories/store_repository.dart';

class StoreOrdersController extends GetxController {
  final StoreRepository _repository = StoreRepository();

  // Order lists
  final RxList<dynamic> pendingOrders = <dynamic>[].obs;
  final RxList<dynamic> preparingOrders = <dynamic>[].obs;
  final RxList<dynamic> readyOrders = <dynamic>[].obs;
  final RxList<dynamic> completedOrders = <dynamic>[].obs;

  // Current order
  final Rxn<dynamic> currentOrder = Rxn<dynamic>();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isUpdatingStatus = false.obs;

  // Tab selection
  final RxInt selectedTab = 0.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  // Pagination
  int _pendingPage = 1;
  int _preparingPage = 1;
  int _readyPage = 1;
  int _completedPage = 1;
  bool _hasMorePending = true;
  bool _hasMorePreparing = true;
  bool _hasMoreReady = true;
  bool _hasMoreCompleted = true;

  @override
  void onInit() {
    super.onInit();
    loadAllOrders();
  }

  /// Load all types of orders
  Future<void> loadAllOrders() async {
    await Future.wait([
      loadPendingOrders(refresh: true),
      loadPreparingOrders(refresh: true),
      loadReadyOrders(refresh: true),
      loadCompletedOrders(refresh: true),
    ]);
  }

  /// Load pending orders
  Future<void> loadPendingOrders({bool refresh = false}) async {
    if (refresh) {
      _pendingPage = 1;
      _hasMorePending = true;
    }

    if (!_hasMorePending && !refresh) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.getOrders(
        type: 'pending',
        page: _pendingPage,
      );

      final List<dynamic> ordersJson = result['orders'] ?? [];

      if (refresh) {
        pendingOrders.value = ordersJson;
      } else {
        pendingOrders.addAll(ordersJson);
      }

      final meta = result['meta'] ?? {};
      _hasMorePending = (_pendingPage < (meta['totalPages'] ?? 1));
      _pendingPage++;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດໂຫຼດ orders ໄດ້');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load preparing orders
  Future<void> loadPreparingOrders({bool refresh = false}) async {
    if (refresh) {
      _preparingPage = 1;
      _hasMorePreparing = true;
    }

    if (!_hasMorePreparing && !refresh) return;

    try {
      final result = await _repository.getOrders(
        type: 'preparing',
        page: _preparingPage,
      );

      final List<dynamic> ordersJson = result['orders'] ?? [];

      if (refresh) {
        preparingOrders.value = ordersJson;
      } else {
        preparingOrders.addAll(ordersJson);
      }

      final meta = result['meta'] ?? {};
      _hasMorePreparing = (_preparingPage < (meta['totalPages'] ?? 1));
      _preparingPage++;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  /// Load ready orders
  Future<void> loadReadyOrders({bool refresh = false}) async {
    if (refresh) {
      _readyPage = 1;
      _hasMoreReady = true;
    }

    if (!_hasMoreReady && !refresh) return;

    try {
      final result = await _repository.getOrders(
        type: 'ready',
        page: _readyPage,
      );

      final List<dynamic> ordersJson = result['orders'] ?? [];

      if (refresh) {
        readyOrders.value = ordersJson;
      } else {
        readyOrders.addAll(ordersJson);
      }

      final meta = result['meta'] ?? {};
      _hasMoreReady = (_readyPage < (meta['totalPages'] ?? 1));
      _readyPage++;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  /// Load completed orders
  Future<void> loadCompletedOrders({bool refresh = false}) async {
    if (refresh) {
      _completedPage = 1;
      _hasMoreCompleted = true;
    }

    if (!_hasMoreCompleted && !refresh) return;

    try {
      final result = await _repository.getOrders(
        type: 'completed',
        page: _completedPage,
      );

      final List<dynamic> ordersJson = result['orders'] ?? [];

      if (refresh) {
        completedOrders.value = ordersJson;
      } else {
        completedOrders.addAll(ordersJson);
      }

      final meta = result['meta'] ?? {};
      _hasMoreCompleted = (_completedPage < (meta['totalPages'] ?? 1));
      _completedPage++;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
    String? cancelReason,
  }) async {
    isUpdatingStatus.value = true;
    errorMessage.value = '';

    try {
      await _repository.updateOrderStatus(
        orderId: orderId,
        status: status,
        cancelReason: cancelReason,
      );

      // Reload orders to refresh state
      await loadAllOrders();

      Get.snackbar(
        'ສຳເລັດ',
        'ອັບເດດສະຖານະແລ້ວ',
        backgroundColor:
            Get.theme?.primaryColor ?? const Color.fromARGB(255, 76, 175, 80),
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('ຜິດພາດ', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  /// Confirm order (PENDING -> CONFIRMED)
  Future<bool> confirmOrder(String orderId) async {
    return updateOrderStatus(orderId: orderId, status: 'CONFIRMED');
  }

  /// Start preparing order (CONFIRMED -> PREPARING)
  Future<bool> startPreparing(String orderId) async {
    return updateOrderStatus(orderId: orderId, status: 'PREPARING');
  }

  /// Mark as ready (PREPARING -> READY_FOR_PICKUP)
  Future<bool> markReady(String orderId) async {
    return updateOrderStatus(orderId: orderId, status: 'READY_FOR_PICKUP');
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    return updateOrderStatus(
      orderId: orderId,
      status: 'CANCELLED',
      cancelReason: reason,
    );
  }

  /// Load more for current tab
  Future<void> loadMore() async {
    switch (selectedTab.value) {
      case 0:
        await loadPendingOrders();
        break;
      case 1:
        await loadPreparingOrders();
        break;
      case 2:
        await loadReadyOrders();
        break;
      case 3:
        await loadCompletedOrders();
        break;
    }
  }

  /// Get current tab orders
  List<dynamic> get currentTabOrders {
    switch (selectedTab.value) {
      case 0:
        return pendingOrders;
      case 1:
        return preparingOrders;
      case 2:
        return readyOrders;
      case 3:
        return completedOrders;
      default:
        return pendingOrders;
    }
  }
}
