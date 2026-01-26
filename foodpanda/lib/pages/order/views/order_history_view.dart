import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/order_history_controller.dart';
import '../widgets/order_card.dart';
import '../widgets/order_empty_state.dart';
import '../widgets/order_shimmer_loading.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.historyOrders),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshOrders,
        color: AppColors.primary,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const OrderShimmerLoading();
          }

          if (controller.activeOrders.isEmpty &&
              controller.orderHistory.isEmpty) {
            return const OrderEmptyState();
          }

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Active Orders
              if (controller.activeOrders.isNotEmpty) ...[
                _buildSectionTitle(AppStrings.activeOrders),
                SizedBox(height: 12.h),
                ...controller.activeOrders.map(
                  (order) => OrderCard(order: order, isActive: true),
                ),
                SizedBox(height: 24.h),
              ],
              // Order History
              if (controller.orderHistory.isNotEmpty) ...[
                _buildSectionTitle(AppStrings.orderHistory),
                SizedBox(height: 12.h),
                ...controller.orderHistory.map(
                  (order) => OrderCard(order: order),
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
}
