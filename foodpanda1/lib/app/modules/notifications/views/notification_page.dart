import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/notification_service.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_empty.dart';
import '../widgets/notification_error.dart';
import '../widgets/notification_item.dart';
import '../widgets/notification_shimmer.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('ການແຈ້ງເຕືອນ'),
      actions: [
        // Mark all as read button
        Obx(() {
          final unreadCount = NotificationService.instance.unreadCount.value;
          if (unreadCount > 0) {
            return TextButton.icon(
              onPressed: controller.markAllAsRead,
              icon: Icon(
                Icons.done_all,
                size: 18.sp,
              ),
              label: const Text('ອ່ານທັງໝົດ'),
            );
          }
          return const SizedBox.shrink();
        }),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildBody() {
    // Loading state
    if (controller.isLoading.value && controller.notifications.isEmpty) {
      return const NotificationShimmer();
    }

    // Error state
    if (controller.hasError.value && controller.notifications.isEmpty) {
      return NotificationError(
        message: controller.errorMessage.value,
        onRetry: controller.loadNotifications,
      );
    }

    // Empty state
    if (!controller.isLoading.value && controller.notifications.isEmpty) {
      return NotificationEmpty(
        onRefresh: controller.loadNotifications,
      );
    }

    // Notification list
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.primary,
      child: _buildNotificationList(),
    );
  }

  Widget _buildNotificationList() {
    final grouped = controller.groupedNotifications;
    final sections = grouped.keys.toList();

    return CustomScrollView(
      slivers: [
        // Unread count header
        Obx(() {
          final unreadCount = NotificationService.instance.unreadCount.value;
          if (unreadCount > 0) {
            return SliverToBoxAdapter(
              child: _buildUnreadHeader(unreadCount),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }),

        // Grouped notifications
        ...sections.map((section) {
          final items = grouped[section]!;
          return SliverMainAxisGroup(
            slivers: [
              // Section header
              SliverToBoxAdapter(
                child: _buildSectionHeader(section),
              ),
              // Section items
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final notification = items[index];
                    return NotificationItem(
                      notification: notification,
                      onTap: () => controller.onNotificationTap(notification),
                      onDismiss: () {
                        // Optional: implement delete
                      },
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 8.h)),
            ],
          );
        }),

        // Load more indicator
        SliverToBoxAdapter(
          child: _buildLoadMoreIndicator(),
        ),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    );
  }

  Widget _buildUnreadHeader(int count) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ທ່ານມີ $count ການແຈ້ງເຕືອນໃໝ່',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'ກົດເພື່ອອ່ານລາຍລະອຽດ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.8),
            size: 24.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      }

      if (controller.hasMore.value && controller.notifications.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Center(
            child: TextButton(
              onPressed: controller.loadMore,
              child: const Text('ໂຫຼດເພີ່ມເຕີມ'),
            ),
          ),
        );
      }

      if (!controller.hasMore.value && controller.notifications.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Center(
            child: Text(
              'ໝົດລາຍການແລ້ວ',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textHint,
              ),
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }
}

