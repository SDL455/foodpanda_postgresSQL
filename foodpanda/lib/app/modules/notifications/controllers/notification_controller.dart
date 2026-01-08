import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();
  final _logger = Logger();

  // Observable states
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;

  // Pagination
  int _currentPage = 1;
  static const int _pageSize = 20;

  // Get unread count from notification service
  int get unreadCount => NotificationService.instance.unreadCount.value;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Load notifications (initial load)
  Future<void> loadNotifications() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    _currentPage = 1;

    try {
      final response = await _repository.getNotifications(
        page: _currentPage,
        limit: _pageSize,
      );

      notifications.value = response.data;
      hasMore.value = _currentPage < response.meta.totalPages;
      
      // Refresh unread count
      NotificationService.instance.refreshUnreadCount();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      _logger.e('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    try {
      _currentPage++;
      final response = await _repository.getNotifications(
        page: _currentPage,
        limit: _pageSize,
      );

      notifications.addAll(response.data);
      hasMore.value = _currentPage < response.meta.totalPages;
    } catch (e) {
      _currentPage--;
      _logger.e('Error loading more notifications: $e');
      Get.snackbar(
        'ຂໍ້ຜິດພາດ',
        'ບໍ່ສາມາດໂຫຼດເພີ່ມເຕີມໄດ້',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Refresh notifications (pull to refresh)
  Future<void> refresh() async {
    await loadNotifications();
  }

  /// Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        notifications.refresh();
      }

      // Update unread count
      NotificationService.instance.refreshUnreadCount();
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      // Update local state
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
      }
      notifications.refresh();

      // Update unread count
      NotificationService.instance.unreadCount.value = 0;

      Get.snackbar(
        'ສຳເລັດ',
        'ໝາຍວ່າອ່ານແລ້ວທັງໝົດ',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _logger.e('Error marking all as read: $e');
      Get.snackbar(
        'ຂໍ້ຜິດພາດ',
        'ບໍ່ສາມາດດຳເນີນການໄດ້',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Handle notification tap
  void onNotificationTap(NotificationModel notification) {
    // Mark as read if not already
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on notification type
    if (notification.orderId != null) {
      Get.toNamed('/orders/${notification.orderId}');
    } else {
      switch (notification.type) {
        case NotificationType.promotion:
          Get.toNamed('/promotions');
          break;
        case NotificationType.chatMessage:
          Get.toNamed('/chat');
          break;
        default:
          // Just mark as read, no navigation
          break;
      }
    }
  }

  /// Get grouped notifications by date
  Map<String, List<NotificationModel>> get groupedNotifications {
    final Map<String, List<NotificationModel>> grouped = {};

    for (final notification in notifications) {
      final date = _getDateLabel(notification.createdAt);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(notification);
    }

    return grouped;
  }

  String _getDateLabel(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'ມື້ນີ້';
    } else if (dateOnly == yesterday) {
      return 'ມື້ວານ';
    } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      return 'ອາທິດນີ້';
    } else if (dateOnly.month == now.month && dateOnly.year == now.year) {
      return 'ເດືອນນີ້';
    } else {
      return 'ກ່ອນໜ້ານີ້';
    }
  }
}

