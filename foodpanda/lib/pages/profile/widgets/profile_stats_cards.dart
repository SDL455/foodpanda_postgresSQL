import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/profile_controller.dart';

class ProfileStatsCards extends GetView<ProfileController> {
  const ProfileStatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.shopping_bag_outlined,
              value: '${user?.totalOrders ?? 0}',
              label: 'ຄຳສັ່ງຊື້',
              color: AppColors.success,
              onTap: controller.goToOrderHistory,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _StatCard(
              icon: Icons.favorite_outline,
              value: '${user?.totalFavorites ?? 0}',
              label: 'ຮ້ານທີ່ມັກ',
              color: AppColors.error,
              onTap: controller.goToFavorites,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _StatCard(
              icon: Icons.star_outline,
              value: '${user?.totalReviews ?? 0}',
              label: 'ລີວິວ',
              color: AppColors.warning,
              onTap: () {}, // TODO: Navigate to reviews
            ),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
