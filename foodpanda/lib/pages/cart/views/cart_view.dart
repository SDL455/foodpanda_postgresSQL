import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/cached_image.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.cart),
        actions: [
          Obx(
            () => controller.cartItems.isNotEmpty
                ? TextButton(
                    onPressed: () async {
                      final confirm = await Helpers.showConfirmDialog(
                        title: AppStrings.clearCart,
                        message: 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການລຶບທັງໝົດ?',
                      );
                      if (confirm) controller.clearCart();
                    },
                    child: Text(
                      AppStrings.clearCart,
                      style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isEmpty) {
          return _buildEmptyCart();
        }
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Restaurant info
                  _buildRestaurantInfo(),
                  SizedBox(height: 16.h),
                  // Cart items
                  _buildCartItems(),
                  SizedBox(height: 16.h),
                  // Order summary
                  _buildOrderSummary(),
                ],
              ),
            ),
            // Checkout button
            _buildCheckoutButton(),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 24.h),
          Text(
            AppStrings.emptyCart,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ເລືອກອາຫານຈາກຮ້ານທີ່ທ່ານມັກ',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 32.h),
          CustomButton(
            text: 'ເລີ່ມສັ່ງອາຫານ',
            onPressed: () => Get.offAllNamed(AppRoutes.main),
            width: 200.w,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    final restaurant = controller.currentRestaurant.value;
    if (restaurant == null) return const SizedBox();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CachedImage(
            imageUrl: restaurant.displayImage,
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
                  restaurant.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  restaurant.deliveryTimeText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.cartItems.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (context, index) {
          final item = controller.cartItems[index];
          return Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => controller.removeItem(item.id),
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  icon: Icons.delete,
                  label: AppStrings.delete,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedImage(
                    imageUrl: ApiConstants.getImageUrl(item.menuItem.image),
                    width: 60.w,
                    height: 60.w,
                    borderRadius: 8.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.menuItem.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (item.note != null && item.note!.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            item.note!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        SizedBox(height: 8.h),
                        Text(
                          Helpers.formatCurrency(item.totalPrice),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quantity controls
                  _buildQuantityControls(item),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuantityControls(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => controller.updateQuantity(item.id, item.quantity - 1),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(Icons.remove, size: 16.sp, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Obx(
              () => Text(
                '${item.quantity}',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          InkWell(
            onTap: () => controller.updateQuantity(item.id, item.quantity + 1),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(Icons.add, size: 16.sp, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            AppStrings.subtotal,
            Helpers.formatCurrency(controller.subtotal),
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            AppStrings.deliveryFee,
            Helpers.formatCurrency(controller.deliveryFee),
          ),
          Divider(height: 24.h, color: AppColors.grey200),
          _buildSummaryRow(
            AppStrings.total,
            Helpers.formatCurrency(controller.total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text:
              '${AppStrings.checkout} • ${Helpers.formatCurrency(controller.total)}',
          onPressed: () => Get.toNamed(AppRoutes.checkout),
        ),
      ),
    );
  }
}
