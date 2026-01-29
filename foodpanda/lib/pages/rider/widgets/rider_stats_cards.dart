import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';

/// Widget ສະແດງສະຖິຕິຂອງ Rider (ສົ່ງວັນນີ້, ລາຍຮັບ, ຄະແນນ)
class RiderStatsCards extends StatelessWidget {
  final RiderController controller;

  const RiderStatsCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.local_shipping,
              label: 'ສົ່ງວັນນີ້',
              value: controller.todayDeliveries,
              color: AppColors.info,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: StatCard(
              icon: Icons.monetization_on,
              label: 'ລາຍຮັບວັນນີ້',
              value: controller.todayEarnings,
              isCurrency: true,
              color: AppColors.success,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: StatCard(
              icon: Icons.star,
              label: 'ຄະແນນ',
              value: controller.rating,
              suffix: '/5',
              color: AppColors.ratingActive,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget ສະແດງ Card ສະຖິຕິແຕ່ລະອັນ
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Rx value;
  final bool isCurrency;
  final String? suffix;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isCurrency = false,
    this.suffix,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildIcon(),
          SizedBox(height: 8.h),
          _buildValue(),
          SizedBox(height: 2.h),
          _buildLabel(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20.sp),
    );
  }

  Widget _buildValue() {
    return Obx(() {
      String displayValue;
      if (isCurrency) {
        // Handle both int and double for currency
        final numValue = value.value;
        if (numValue is int) {
          displayValue = '${numValue}₭';
        } else if (numValue is double) {
          displayValue = '${numValue.toStringAsFixed(0)}₭';
        } else {
          displayValue = '${numValue}₭';
        }
      } else if (value.value is double) {
        displayValue = '${value.value}${suffix ?? ''}';
      } else {
        displayValue = '${value.value}${suffix ?? ''}';
      }
      return Text(
        displayValue,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    });
  }

  Widget _buildLabel() {
    return Text(
      label,
      style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
    );
  }
}
