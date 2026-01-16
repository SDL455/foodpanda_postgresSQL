import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_delivery_controller.dart';

/// Widget ສະແດງ Tab Bar ສຳລັບເລືອກປະເພດງານສົ່ງ
class DeliveryTabBar extends StatelessWidget {
  final RiderDeliveryController controller;

  const DeliveryTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: Obx(
        () => Row(
          children: [
            DeliveryTabItem(
              controller: controller,
              index: 0,
              label: 'ງານໃໝ່',
              count: controller.availableDeliveries.length,
            ),
            SizedBox(width: 12.w),
            DeliveryTabItem(
              controller: controller,
              index: 1,
              label: 'ກຳລັງສົ່ງ',
              count: controller.activeDeliveries.length,
            ),
            SizedBox(width: 12.w),
            DeliveryTabItem(
              controller: controller,
              index: 2,
              label: 'ສຳເລັດ',
              count: controller.completedDeliveries.length,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget ສະແດງ Tab Item ແຕ່ລະອັນ
class DeliveryTabItem extends StatelessWidget {
  final RiderDeliveryController controller;
  final int index;
  final String label;
  final int count;

  const DeliveryTabItem({
    super.key,
    required this.controller,
    required this.index,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.selectedTab.value == index;

    return Expanded(
      child: InkWell(
        onTap: () => controller.selectedTab.value = index,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey300,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              _buildCountBadge(isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountBadge(bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.white.withOpacity(0.2)
            : AppColors.grey200,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: isSelected ? AppColors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
