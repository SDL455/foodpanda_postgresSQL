import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/rider_repository.dart';
import 'rider_delivery_controller.dart';

/// Controller ສຳລັບຈັດການ notifications ຂອງ rider
class RiderNotificationController extends GetxController {
  final RiderRepository _repository = RiderRepository();

  // Notifications list
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  // Unread count
  final RxInt unreadCount = 0.obs;

  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  // Error
  final RxString errorMessage = ''.obs;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
  }

  /// Load notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    if (refresh) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    errorMessage.value = '';

    try {
      final result = await _repository.getNotifications(
        page: _currentPage,
        limit: _pageSize,
      );

      if (refresh) {
        notifications.value = result;
      } else {
        notifications.addAll(result);
      }

      _hasMore = result.length >= _pageSize;
      _currentPage++;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      unreadCount.value = await _repository.getUnreadNotificationCount();
    } catch (e) {
      // Ignore error for unread count
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await Future.wait([
      loadNotifications(refresh: true),
      loadUnreadCount(),
    ]);
  }

  /// Load more notifications
  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore.value) return;
    await loadNotifications();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markNotificationAsRead(notificationId);

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = notifications[index];
        if (!notification.isRead) {
          notifications[index] = notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          if (unreadCount.value > 0) {
            unreadCount.value--;
          }
        }
      }
    } catch (e) {
      // Ignore error
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();

      // Update local state
      notifications.value = notifications
          .map(
            (n) =>
                n.isRead ? n : n.copyWith(isRead: true, readAt: DateTime.now()),
          )
          .toList();
      unreadCount.value = 0;

      Get.snackbar('ສຳເລັດ', 'ໝາຍວ່າອ່ານທັງໝົດແລ້ວ');
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດໝາຍວ່າອ່ານໄດ້');
    }
  }

  /// Handle notification tap
  void onNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on notification type
    if (notification.isNewDelivery || notification.isDeliveryAssigned) {
      // Navigate to delivery detail or refresh deliveries
      _handleDeliveryNotification(notification);
    } else if (notification.orderId != null) {
      // Navigate to order detail
      Get.toNamed('/rider/delivery/${notification.orderId}');
    }
  }

  /// Handle delivery notification
  void _handleDeliveryNotification(NotificationModel notification) {
    // Refresh deliveries list
    final deliveryController = Get.find<RiderDeliveryController>();
    deliveryController.refreshDeliveries();

    // Navigate to home
    Get.offAllNamed('/rider');
  }

  /// Handle push notification received
  void handlePushNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    if (type == 'NEW_DELIVERY' || type == 'DELIVERY_ASSIGNED') {
      // Refresh deliveries
      if (Get.isRegistered<RiderDeliveryController>()) {
        final deliveryController = Get.find<RiderDeliveryController>();
        deliveryController.handleNewDeliveryNotification(data);
      }
    }

    // Refresh notification list and count
    refresh();
  }

  /// Add new notification from push
  void addNotificationFromPush(Map<String, dynamic> data) {
    final notification = NotificationModel(
      id: data['notificationId'] ?? DateTime.now().toIso8601String(),
      riderId: data['riderId'],
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'],
      orderId: data['orderId'],
      data: data,
      isRead: false,
      createdAt: DateTime.now(),
    );

    // Add to top of list
    notifications.insert(0, notification);
    unreadCount.value++;
  }

  bool get hasMore => _hasMore;
}
