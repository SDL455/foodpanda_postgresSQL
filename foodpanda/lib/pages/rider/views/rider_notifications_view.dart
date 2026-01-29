import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_notification_controller.dart';
import '../widgets/rider_notification_card.dart';

/// ໜ້າ notifications ສຳລັບ rider
class RiderNotificationsView extends GetView<RiderNotificationController> {
  const RiderNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primary,
          child: _buildNotificationList(),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'ແຈ້ງເຕືອນ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Obx(() {
          if (controller.unreadCount.value > 0) {
            return TextButton(
              onPressed: controller.markAllAsRead,
              child: const Text(
                'ອ່ານທັງໝົດ',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'ບໍ່ມີການແຈ້ງເຕືອນ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ການແຈ້ງເຕືອນໃໝ່ຈະປະກົດຢູ່ນີ້',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.notifications.length + 1,
      itemBuilder: (context, index) {
        if (index == controller.notifications.length) {
          return _buildLoadMoreButton();
        }

        final notification = controller.notifications[index];
        return RiderNotificationCard(
          notification: notification,
          onTap: () => controller.onNotificationTap(notification),
        );
      },
    );
  }

  Widget _buildLoadMoreButton() {
    return Obx(() {
      if (!controller.hasMore) {
        return const SizedBox.shrink();
      }

      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton(
            onPressed: controller.loadMore,
            child: const Text('ໂຫຼດເພີ່ມ'),
          ),
        ),
      );
    });
  }
}
