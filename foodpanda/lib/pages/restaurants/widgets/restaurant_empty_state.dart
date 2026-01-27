import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/restaurants_controller.dart';

class RestaurantEmptyState extends GetView<RestaurantsController> {
  const RestaurantEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64.sp,
            color: AppColors.grey400,
          ),
          SizedBox(height: 16.h),
          Text(
            'ບໍ່ມີຮ້ານອາຫານ',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return Column(
                children: [
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: controller.clearSearch,
                    child: Text(
                      'ລ້າງການຄົ້ນຫາ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
