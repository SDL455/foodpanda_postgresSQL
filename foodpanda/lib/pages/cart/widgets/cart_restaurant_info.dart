import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../widgets/cached_image.dart';

class CartRestaurantInfo extends StatelessWidget {
  final RestaurantModel? restaurant;

  const CartRestaurantInfo({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
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
            imageUrl: restaurant!.displayImage,
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
                  restaurant!.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  restaurant!.deliveryTimeText,
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
}
