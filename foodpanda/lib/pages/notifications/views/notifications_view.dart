import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/notification_model.dart';
import '../../../widgets/shimmer_loading.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('ການແຈ້ງເຕືອນ'),
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return TextButton(
                onPressed: controller.markAllAsRead,
                child: Text(
                  'ອ່ານທັງໝົດ',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshNotifications,
        color: AppColors.primary,
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading();
          }

          if (controller.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                controller.loadMoreNotifications();
              }
              return false;
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount:
                  controller.notifications.length +
                  (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.notifications.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildNotificationCard(controller.notifications[index]);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.white
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: notification.isRead
            ? null
            : Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => controller.handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(notification.type),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _getIconForType(notification.type),
                  color: _getIconColor(notification.type),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'order':
        return Icons.receipt_long;
      case 'promotion':
        return Icons.local_offer;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconBackgroundColor(String? type) {
    switch (type) {
      case 'order':
        return AppColors.success.withOpacity(0.1);
      case 'promotion':
        return AppColors.warning.withOpacity(0.1);
      case 'system':
        return AppColors.info.withOpacity(0.1);
      default:
        return AppColors.primaryLight;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'order':
        return AppColors.success;
      case 'promotion':
        return AppColors.warning;
      case 'system':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'ຫາກໍ';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ນາທີກ່ອນ';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ຊົ່ວໂມງກ່ອນ';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ວັນກ່ອນ';
    } else {
      return Helpers.formatDate(dateTime);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 100.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 24.h),
          Text(
            'ບໍ່ມີການແຈ້ງເຕືອນ',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ການແຈ້ງເຕືອນຈະສະແດງຢູ່ບ່ອນນີ້',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ShimmerLoading(
        child: Column(
          children: List.generate(
            5,
            (index) => Container(
              height: 90.h,
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
