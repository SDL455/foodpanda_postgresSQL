import 'package:get/get.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/repositories/rider_repository.dart';

class RiderDeliveryController extends GetxController {
  final RiderRepository _repository = RiderRepository();

  // Delivery lists
  final RxList<DeliveryModel> availableDeliveries = <DeliveryModel>[].obs;
  final RxList<DeliveryModel> activeDeliveries = <DeliveryModel>[].obs;
  final RxList<DeliveryModel> completedDeliveries = <DeliveryModel>[].obs;

  // Current delivery being viewed/managed
  final Rxn<DeliveryModel> currentDelivery = Rxn<DeliveryModel>();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isAccepting = false.obs;
  final RxBool isUpdatingStatus = false.obs;

  // Tab selection
  final RxInt selectedTab = 0.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  // Pagination
  int _availablePage = 1;
  int _activePage = 1;
  int _completedPage = 1;
  bool _hasMoreAvailable = true;
  bool _hasMoreActive = true;
  bool _hasMoreCompleted = true;

  @override
  void onInit() {
    super.onInit();
    loadAllDeliveries();
  }

  /// Load all types of deliveries
  Future<void> loadAllDeliveries() async {
    await Future.wait([
      loadAvailableDeliveries(refresh: true),
      loadActiveDeliveries(refresh: true),
      loadCompletedDeliveries(refresh: true),
    ]);
  }

  /// Load available deliveries (orders ready for pickup)
  Future<void> loadAvailableDeliveries({bool refresh = false}) async {
    if (refresh) {
      _availablePage = 1;
      _hasMoreAvailable = true;
    }

    if (!_hasMoreAvailable && !refresh) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.getDeliveries(
        type: 'available',
        page: _availablePage,
      );

      final List<dynamic> deliveriesJson = result['deliveries'] ?? [];
      final deliveries =
          deliveriesJson.map((e) => DeliveryModel.fromJson(e)).toList();

      if (refresh) {
        availableDeliveries.value = deliveries;
      } else {
        availableDeliveries.addAll(deliveries);
      }

      final meta = result['meta'] ?? {};
      _hasMoreAvailable = (_availablePage < (meta['totalPages'] ?? 1));
      _availablePage++;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດໂຫຼດ deliveries ໄດ້');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load active deliveries (orders being delivered)
  Future<void> loadActiveDeliveries({bool refresh = false}) async {
    if (refresh) {
      _activePage = 1;
      _hasMoreActive = true;
    }

    if (!_hasMoreActive && !refresh) return;

    try {
      final result = await _repository.getDeliveries(
        type: 'active',
        page: _activePage,
      );

      final List<dynamic> deliveriesJson = result['deliveries'] ?? [];
      final deliveries =
          deliveriesJson.map((e) => DeliveryModel.fromJson(e)).toList();

      if (refresh) {
        activeDeliveries.value = deliveries;
      } else {
        activeDeliveries.addAll(deliveries);
      }

      final meta = result['meta'] ?? {};
      _hasMoreActive = (_activePage < (meta['totalPages'] ?? 1));
      _activePage++;

      // Set current delivery if there's an active one
      if (activeDeliveries.isNotEmpty && currentDelivery.value == null) {
        currentDelivery.value = activeDeliveries.first;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  /// Load completed deliveries
  Future<void> loadCompletedDeliveries({bool refresh = false}) async {
    if (refresh) {
      _completedPage = 1;
      _hasMoreCompleted = true;
    }

    if (!_hasMoreCompleted && !refresh) return;

    try {
      final result = await _repository.getDeliveries(
        type: 'completed',
        page: _completedPage,
      );

      final List<dynamic> deliveriesJson = result['deliveries'] ?? [];
      final deliveries =
          deliveriesJson.map((e) => DeliveryModel.fromJson(e)).toList();

      if (refresh) {
        completedDeliveries.value = deliveries;
      } else {
        completedDeliveries.addAll(deliveries);
      }

      final meta = result['meta'] ?? {};
      _hasMoreCompleted = (_completedPage < (meta['totalPages'] ?? 1));
      _completedPage++;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  /// Accept a delivery
  Future<bool> acceptDelivery(DeliveryModel delivery) async {
    isAccepting.value = true;
    errorMessage.value = '';

    try {
      await _repository.acceptDelivery(delivery.orderId);

      // Remove from available and add to active
      availableDeliveries.removeWhere((d) => d.orderId == delivery.orderId);

      // Reload active deliveries to get updated data
      await loadActiveDeliveries(refresh: true);

      // Set as current delivery
      if (activeDeliveries.isNotEmpty) {
        currentDelivery.value = activeDeliveries.first;
      }

      Get.snackbar('ສຳເລັດ', 'ຮັບ Order ${delivery.orderNo} ແລ້ວ');
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('ຜິດພາດ', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isAccepting.value = false;
    }
  }

  /// Update delivery status
  Future<bool> updateDeliveryStatus(
    DeliveryStatus newStatus, {
    double? currentLat,
    double? currentLng,
    String? note,
  }) async {
    if (currentDelivery.value == null) return false;

    isUpdatingStatus.value = true;
    errorMessage.value = '';

    try {
      await _repository.updateDeliveryStatus(
        orderId: currentDelivery.value!.orderId,
        status: newStatus.value,
        currentLat: currentLat,
        currentLng: currentLng,
        note: note,
      );

      if (newStatus == DeliveryStatus.delivered) {
        // Move to completed
        activeDeliveries
            .removeWhere((d) => d.orderId == currentDelivery.value!.orderId);
        currentDelivery.value = null;

        // Reload completed deliveries
        await loadCompletedDeliveries(refresh: true);

        // Set next active delivery if any
        if (activeDeliveries.isNotEmpty) {
          currentDelivery.value = activeDeliveries.first;
        }

        Get.snackbar('ສຳເລັດ', 'ສົ່ງ Order ສຳເລັດແລ້ວ');
      } else {
        // Reload to get updated status
        await loadActiveDeliveries(refresh: true);

        if (activeDeliveries.isNotEmpty) {
          currentDelivery.value = activeDeliveries.firstWhere(
            (d) => d.orderId == currentDelivery.value!.orderId,
            orElse: () => activeDeliveries.first,
          );
        }

        Get.snackbar('ສຳເລັດ', 'ອັບເດດສະຖານະແລ້ວ');
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('ຜິດພາດ', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  /// Go to next status
  Future<bool> proceedToNextStatus({
    double? currentLat,
    double? currentLng,
  }) async {
    final nextStatus = currentDelivery.value?.nextStatus;
    if (nextStatus == null) return false;

    return updateDeliveryStatus(
      nextStatus,
      currentLat: currentLat,
      currentLng: currentLng,
    );
  }

  /// Set current delivery for detail view
  void setCurrentDelivery(DeliveryModel delivery) {
    currentDelivery.value = delivery;
  }

  /// Refresh all deliveries
  Future<void> refreshDeliveries() async {
    await loadAllDeliveries();
  }

  /// Handle new delivery notification
  void handleNewDeliveryNotification(Map<String, dynamic> data) {
    // Reload available deliveries when we receive a new delivery notification
    loadAvailableDeliveries(refresh: true);
  }

  /// Get status text
  String getStatusText(DeliveryStatus status) {
    return status.label;
  }

  /// Get deliveries for current tab
  List<DeliveryModel> get currentTabDeliveries {
    switch (selectedTab.value) {
      case 0:
        return availableDeliveries;
      case 1:
        return activeDeliveries;
      case 2:
        return completedDeliveries;
      default:
        return availableDeliveries;
    }
  }

  /// Check if can load more for current tab
  bool get canLoadMore {
    switch (selectedTab.value) {
      case 0:
        return _hasMoreAvailable;
      case 1:
        return _hasMoreActive;
      case 2:
        return _hasMoreCompleted;
      default:
        return false;
    }
  }

  /// Load more for current tab
  Future<void> loadMore() async {
    switch (selectedTab.value) {
      case 0:
        await loadAvailableDeliveries();
        break;
      case 1:
        await loadActiveDeliveries();
        break;
      case 2:
        await loadCompletedDeliveries();
        break;
    }
  }
}
