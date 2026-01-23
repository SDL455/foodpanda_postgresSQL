import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';
import '../../../routes/app_routes.dart';

class NotificationsController extends GetxController {
  final ProfileRepository _repository = ProfileRepository();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  // Pagination
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        isLoading.value = true;
      }

      final data = await _repository.getNotifications(
        page: _currentPage,
        limit: _limit,
      );

      final newNotifications = data
          .map((e) => NotificationModel.fromJson(e))
          .toList();

      if (refresh) {
        notifications.value = newNotifications;
      } else {
        notifications.addAll(newNotifications);
      }

      _hasMore = newNotifications.length >= _limit;
      _currentPage++;
    } catch (e) {
      LoggerService.error('Failed to load notifications', e);
      if (refresh) {
        Helpers.showSnackbar(
          title: 'ຂໍ້ຜິດພາດ',
          message: 'ບໍ່ສາມາດໂຫຼດການແຈ້ງເຕືອນໄດ້',
          isError: true,
        );
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await _repository.getUnreadNotificationCount();
      unreadCount.value = count;
    } catch (e) {
      LoggerService.error('Failed to load unread count', e);
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
    await loadUnreadCount();
  }

  Future<void> loadMoreNotifications() async {
    if (!_hasMore || isLoadingMore.value) return;

    isLoadingMore.value = true;
    await loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markNotificationAsRead(id);

      // Update local state
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !notifications[index].isRead) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
      }
    } catch (e) {
      LoggerService.error('Failed to mark notification as read', e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      Helpers.showLoading(message: 'ກຳລັງດຳເນີນການ...');
      await _repository.markAllNotificationsAsRead();
      Helpers.hideLoading();

      // Update local state
      notifications.value = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      unreadCount.value = 0;

      Helpers.showSnackbar(
        title: 'ສຳເລັດ',
        message: 'ອ່ານການແຈ້ງເຕືອນທັງໝົດແລ້ວ',
      );
    } catch (e) {
      Helpers.hideLoading();
      LoggerService.error('Failed to mark all as read', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດດຳເນີນການໄດ້',
        isError: true,
      );
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    // Mark as read first
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case 'order':
        if (notification.referenceId != null) {
          Get.toNamed(
            AppRoutes.orderDetail,
            arguments: {'orderId': notification.referenceId},
          );
        }
        break;
      case 'promotion':
        // Navigate to promotion detail
        break;
      default:
        // Just show notification detail
        _showNotificationDetail(notification);
        break;
    }
  }

  void _showNotificationDetail(NotificationModel notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ປິດ')),
        ],
      ),
    );
  }
}
