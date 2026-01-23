import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/checkout_delivery_address.dart';
import '../widgets/checkout_order_items.dart';
import '../widgets/checkout_payment_method.dart';
import '../widgets/checkout_price_summary.dart';
import '../widgets/checkout_place_order_button.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('ຊຳລະເງິນ'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Delivery Address Section
                  const CheckoutDeliveryAddress(),
                  SizedBox(height: 16.h),

                  // Order Items Section
                  const CheckoutOrderItems(),
                  SizedBox(height: 16.h),

                  // Payment Method Section
                  const CheckoutPaymentMethod(),
                  SizedBox(height: 16.h),

                  // Note Section
                  _buildNoteSection(),
                  SizedBox(height: 16.h),

                  // Price Summary Section
                  const CheckoutPriceSummary(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),

            // Place Order Button
            const CheckoutPlaceOrderButton(),
          ],
        );
      }),
    );
  }

  Widget _buildNoteSection() {
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
            'ໝາຍເຫດ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller.noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'ເພີ່ມໝາຍເຫດສຳລັບຄຳສັ່ງຊື້ (ທາງເລືອກ)',
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
        ],
      ),
    );
  }
}
