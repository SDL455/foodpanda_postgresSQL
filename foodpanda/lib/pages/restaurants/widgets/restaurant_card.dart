import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../routes/app_routes.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantCard({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.restaurantDetail, arguments: restaurant),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Restaurant Image
            _buildRestaurantImage(),
            SizedBox(width: 12.w),
            // Restaurant Info
            Expanded(
              child: _buildRestaurantInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(
            restaurant.displayImage,
            width: 100.w,
            height: 100.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.restaurant,
                size: 40.sp,
                color: AppColors.grey400,
              ),
            ),
          ),
        ),
        // Status badge
        if (!restaurant.isActive)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'ປິດ',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRestaurantInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and favorite
        _buildNameRow(),
        SizedBox(height: 4.h),
        // Address
        if (restaurant.address != null)
          Text(
            restaurant.address!,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        SizedBox(height: 8.h),
        // Rating, reviews, delivery time
        _buildRatingRow(),
        SizedBox(height: 6.h),
        // Delivery fee and total orders
        _buildDeliveryRow(),
      ],
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            restaurant.name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (restaurant.isFavorite)
          Icon(
            Icons.favorite,
            color: AppColors.primary,
            size: 18.sp,
          ),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: AppColors.ratingActive,
          size: 14.sp,
        ),
        SizedBox(width: 4.w),
        Text(
          restaurant.rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          ' (${restaurant.reviewCount})',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          width: 4.w,
          height: 4.w,
          decoration: const BoxDecoration(
            color: AppColors.grey400,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12.w),
        Icon(
          Icons.access_time,
          color: AppColors.grey500,
          size: 14.sp,
        ),
        SizedBox(width: 4.w),
        Text(
          restaurant.deliveryTimeText,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryRow() {
    return Row(
      children: [
        Icon(
          Icons.delivery_dining,
          color: AppColors.grey500,
          size: 14.sp,
        ),
        SizedBox(width: 4.w),
        Text(
          restaurant.deliveryFeeText,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        if (restaurant.totalOrders > 0) ...[
          SizedBox(width: 12.w),
          Container(
            width: 4.w,
            height: 4.w,
            decoration: const BoxDecoration(
              color: AppColors.grey400,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.grey500,
            size: 14.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            '${restaurant.totalOrders}+ ຄຳສັ່ງ',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
