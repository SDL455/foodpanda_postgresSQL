import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/notification_service.dart';

/// A notification bell icon with badge
/// Use this in AppBar or bottom navigation
class NotificationBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final double? iconSize;

  const NotificationBadge({
    super.key,
    this.onTap,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => Get.toNamed('/notifications'),
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_outlined,
              color: iconColor ?? AppColors.textPrimary,
              size: iconSize ?? 24.sp,
            ),
            Obx(() {
              final count = NotificationService.instance.unreadCount.value;
              if (count <= 0) return const SizedBox.shrink();

              return Positioned(
                right: -4.w,
                top: -4.h,
                child: _buildBadge(count),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int count) {
    final displayText = count > 99 ? '99+' : count.toString();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: count > 9 ? 4.w : 0,
        vertical: 2.h,
      ),
      constraints: BoxConstraints(
        minWidth: 18.w,
        minHeight: 18.w,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// A simple notification dot indicator
class NotificationDot extends StatelessWidget {
  final Color? color;
  final double? size;

  const NotificationDot({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = NotificationService.instance.unreadCount.value;
      if (count <= 0) return const SizedBox.shrink();

      return Container(
        width: size ?? 8.w,
        height: size ?? 8.w,
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          shape: BoxShape.circle,
        ),
      );
    });
  }
}

