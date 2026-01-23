import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_restaurant_info.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_order_summary.dart';
import '../widgets/cart_checkout_button.dart';

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
          return const CartEmptyState();
        }
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Restaurant info
                  CartRestaurantInfo(
                    restaurant: controller.currentRestaurant.value,
                  ),
                  SizedBox(height: 16.h),
                  // Cart items
                  _buildCartItems(),
                  SizedBox(height: 16.h),
                  // Order summary
                  CartOrderSummary(
                    subtotal: controller.subtotal,
                    deliveryFee: controller.deliveryFee,
                    total: controller.total,
                  ),
                ],
              ),
            ),
            // Checkout button
            CartCheckoutButton(total: controller.total),
          ],
        );
      }),
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
          return CartItemCard(
            item: item,
            onRemove: controller.removeItem,
            onUpdateQuantity: controller.updateQuantity,
          );
        },
      ),
    );
  }
}
