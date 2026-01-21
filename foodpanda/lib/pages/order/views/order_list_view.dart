import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/shimmer_loading.dart';
import '../controllers/order_controller.dart';
import '../../../data/models/order_model.dart';

class OrderListView extends GetView<OrderController> {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.orders),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshOrders,
        color: AppColors.primary,
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading();
          }

          if (controller.activeOrders.isEmpty &&
              controller.orderHistory.isEmpty) {
            return _buildEmptyOrders();
          }

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Active Orders
              if (controller.activeOrders.isNotEmpty) ...[
                _buildSectionTitle(AppStrings.activeOrders),
                SizedBox(height: 12.h),
                ...controller.activeOrders.map(
                  (order) => _buildOrderCard(order, isActive: true),
                ),
                SizedBox(height: 24.h),
              ],
              // Order History
              if (controller.orderHistory.isNotEmpty) ...[
                _buildSectionTitle(AppStrings.orderHistory),
                SizedBox(height: 12.h),
                ...controller.orderHistory.map(
                  (order) => _buildOrderCard(order),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, {bool isActive = false}) {
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
              // Header
              Row(
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
                  _buildStatusChip(order.status),
                ],
              ),
              SizedBox(height: 12.h),
              Divider(height: 1, color: AppColors.grey200),
              SizedBox(height: 12.h),
              // Items summary
              Text(
                '${order.items.length} ລາຍການ',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              // Total and actions
              Row(
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
                      onPressed: () {
                        // Reorder logic
                      },
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
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
      case OrderStatus.ready:
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        break;
      case OrderStatus.onTheWay:
        backgroundColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        break;
      case OrderStatus.delivered:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case OrderStatus.cancelled:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'ລໍຖ້າ';
      case OrderStatus.confirmed:
        return 'ຢືນຢັນແລ້ວ';
      case OrderStatus.preparing:
        return 'ກຳລັງກະກຽມ';
      case OrderStatus.ready:
        return 'ພ້ອມສົ່ງ';
      case OrderStatus.onTheWay:
        return 'ກຳລັງສົ່ງ';
      case OrderStatus.delivered:
        return 'ສົ່ງແລ້ວ';
      case OrderStatus.cancelled:
        return 'ຍົກເລີກ';
    }
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 24.h),
          Text(
            'ຍັງບໍ່ມີຄຳສັ່ງຊື້',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ເລີ່ມສັ່ງອາຫານທຳອິດຂອງທ່ານ',
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
            3,
            (index) => Container(
              height: 150.h,
              margin: EdgeInsets.only(bottom: 12.h),
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
