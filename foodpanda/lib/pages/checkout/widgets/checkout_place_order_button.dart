import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../widgets/custom_button.dart';
import '../controllers/checkout_controller.dart';

class CheckoutPlaceOrderButton extends GetView<CheckoutController> {
  const CheckoutPlaceOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Obx(() {
          final paymentMethod = controller.currentPaymentMethod;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment method indicator
              if (paymentMethod != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        paymentMethod.icon,
                        size: 18.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'ຊຳລະດ້ວຍ ${paymentMethod.name}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              // Place Order Button
              CustomButton(
                text: 'ສັ່ງອາຫານ • ${Helpers.formatCurrency(controller.total)}',
                onPressed: controller.canPlaceOrder
                    ? controller.placeOrder
                    : () {},
                isLoading: controller.isPlacingOrder.value,
                isDisabled: !controller.canPlaceOrder,
              ),

              // Security note
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14.sp,
                    color: AppColors.textHint,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'ການຊຳລະເງິນປອດໄພ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
