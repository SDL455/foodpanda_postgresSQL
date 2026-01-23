import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/food_detail_controller.dart';

class FoodQuantitySelector extends GetView<FoodDetailController> {
  const FoodQuantitySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: controller.decrementQuantity,
              icon: Icon(
                Icons.remove,
                color: controller.quantity.value > 1
                    ? AppColors.primary
                    : AppColors.grey400,
              ),
            ),
            Container(
              width: 48.w,
              alignment: Alignment.center,
              child: Text(
                controller.quantity.value.toString(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: controller.incrementQuantity,
              icon: Icon(Icons.add, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
