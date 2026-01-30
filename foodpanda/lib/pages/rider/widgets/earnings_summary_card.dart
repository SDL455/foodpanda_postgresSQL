import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';

/// Widget ສະແດງສະຫຼຸບລາຍຮັບທັງໝົດ
class EarningsSummaryCard extends StatelessWidget {
  final RiderController controller;

  const EarningsSummaryCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTotalLabel(),
          SizedBox(height: 8.h),
          _buildTotalAmount(),
          SizedBox(height: 24.h),
          _buildSummaryRow(),
        ],
      ),
    );
  }

  Widget _buildTotalLabel() {
    return Text(
      'ລາຍຮັບທັງໝົດ',
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Obx(
      () => Text(
        '${controller.totalEarnings.value}₭',
        style: TextStyle(
          fontSize: 36.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: EarningsSummaryItem(
            icon: Icons.today,
            label: 'ວັນນີ້',
            value: controller.todayEarnings,
          ),
        ),
        Container(
          width: 1,
          height: 50.h,
          color: AppColors.white.withOpacity(0.3),
        ),
        Expanded(
          child: EarningsSummaryItem(
            icon: Icons.local_shipping,
            label: 'ສົ່ງແລ້ວ',
            value: controller.todayDeliveries,
            isCurrency: false,
            suffix: ' ເທື່ອ',
          ),
        ),
      ],
    );
  }
}

/// Widget ສະແດງລາຍການສະຫຼຸບແຕ່ລະອັນ
class EarningsSummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Rx value;
  final bool isCurrency;
  final String suffix;

  const EarningsSummaryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isCurrency = true,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white.withOpacity(0.8), size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4.h),
        Obx(() {
          String displayValue;
          if (isCurrency) {
            // Safely convert to double: API may return int or double
            final v = value.value;
            final double n = (v is num)
                ? v.toDouble()
                : double.tryParse(v.toString()) ?? 0.0;
            displayValue = '${n.toStringAsFixed(0)}₭';
          } else {
            displayValue = '${value.value}$suffix';
          }
          return Text(
            displayValue,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          );
        }),
      ],
    );
  }
}
