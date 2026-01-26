import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/cached_image.dart';
import '../../../data/models/order_model.dart';
import '../controllers/order_history_controller.dart';
import 'order_status_chip.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isActive;

  const OrderCard({
    super.key,
    required this.order,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: order),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              Divider(height: 1, color: AppColors.grey200),
              SizedBox(height: 12.h),
              _buildItemsSummary(),
              SizedBox(height: 8.h),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CachedImage(
          imageUrl: order.restaurant.displayImage,
          width: 50.w,
          height: 50.w,
          borderRadius: 8.r,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.restaurant.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                Helpers.formatDateTime(order.createdAt),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        OrderStatusChip(status: order.status),
      ],
    );
  }

  Widget _buildItemsSummary() {
    return Text(
      '${order.items.length} ລາຍການ',
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildFooter() {
    final controller = Get.find<OrderHistoryController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          Helpers.formatCurrency(order.total),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Row(
          children: [
            if (isActive && order.canCancel)
              TextButton(
                onPressed: () => controller.cancelOrder(order.id),
                child: Text(
                  AppStrings.cancel,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            if (isActive)
              ElevatedButton(
                onPressed: () =>
                    Get.toNamed(AppRoutes.trackOrder, arguments: order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
                child: Text(
                  AppStrings.trackOrder,
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            if (!isActive)
              OutlinedButton(
                onPressed: () => controller.reorder(order),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
                child: Text(
                  AppStrings.reorder,
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
