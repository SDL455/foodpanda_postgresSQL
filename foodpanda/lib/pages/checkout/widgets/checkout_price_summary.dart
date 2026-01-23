import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../controllers/checkout_controller.dart';

class CheckoutPriceSummary extends GetView<CheckoutController> {
  const CheckoutPriceSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ສະຫຼຸບລາຄາ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            return Column(
              children: [
                _buildPriceRow(
                  'ລວມຍ່ອຍ',
                  Helpers.formatCurrency(controller.subtotal),
                ),
                SizedBox(height: 8.h),
                _buildPriceRow(
                  'ຄ່າສົ່ງ',
                  controller.deliveryFee > 0
                      ? Helpers.formatCurrency(controller.deliveryFee)
                      : 'ຟຣີ',
                  valueColor: controller.deliveryFee > 0
                      ? AppColors.textPrimary
                      : AppColors.secondary,
                ),
                SizedBox(height: 12.h),
                Divider(color: AppColors.grey200),
                SizedBox(height: 12.h),
                _buildPriceRow(
                  'ລວມທັງໝົດ',
                  Helpers.formatCurrency(controller.total),
                  isBold: true,
                  labelColor: AppColors.textPrimary,
                  valueColor: AppColors.primary,
                  fontSize: 18.sp,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? labelColor,
    Color? valueColor,
    double? fontSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: labelColor ?? AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize ?? 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
