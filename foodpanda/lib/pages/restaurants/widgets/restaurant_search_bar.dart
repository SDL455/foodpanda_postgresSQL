import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/restaurants_controller.dart';

class RestaurantSearchBar extends GetView<RestaurantsController> {
  const RestaurantSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: AppColors.white,
      child: TextField(
        onChanged: (value) {
          // Debounce search
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value == controller.searchQuery.value) return;
            controller.search(value);
          });
        },
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.grey500,
            size: 20.sp,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: Icon(
                  Icons.clear,
                  color: AppColors.grey500,
                  size: 20.sp,
                ),
                onPressed: controller.clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
          filled: true,
          fillColor: AppColors.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}
