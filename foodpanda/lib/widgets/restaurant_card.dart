import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../data/models/restaurant_model.dart';
import 'cached_image.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;
  final bool isHorizontal;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard();
    }
    return _buildVerticalCard();
  }

  Widget _buildVerticalCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                CachedImage(
                  imageUrl: restaurant.displayImage,
                  width: double.infinity,
                  height: 120.h,
                  borderRadius: 12.r,
                  borderRadiusOnly: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                // Discount badge or favorite
                if (restaurant.isFavorite)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
                    ),
                  ),
                // Store status badge
                if (!restaurant.isActive)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey800.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'ປິດ',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // Rating and delivery time
                  Row(
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
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(${restaurant.reviewCount})',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: const BoxDecoration(
                          color: AppColors.grey400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        restaurant.deliveryTimeText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Delivery fee
                  Text(
                    'ຄ່າສົ່ງ ${restaurant.deliveryFeeText}',
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
      ),
    );
  }

  Widget _buildHorizontalCard() {
    // Get category names if available
    List<String> categoryNames = [];
    if (restaurant.categories != null) {
      for (var cat in restaurant.categories!.take(2)) {
        if (cat is Map && cat['name'] != null) {
          categoryNames.add(cat['name']);
        } else if (cat is String) {
          categoryNames.add(cat);
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image with status overlay
            Stack(
              children: [
                CachedImage(
                  imageUrl: restaurant.displayImage,
                  width: 90.w,
                  height: 90.w,
                  borderRadius: 8.r,
                ),
                if (!restaurant.isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          'ປິດ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
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
                  ),
                  SizedBox(height: 4.h),
                  // Categories or address
                  if (categoryNames.isNotEmpty)
                    Text(
                      categoryNames.join(' • '),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (restaurant.address != null)
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
                  // Rating, delivery time, distance
                  Row(
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
                          fontWeight: FontWeight.w500,
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
                      SizedBox(width: 8.w),
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: const BoxDecoration(
                          color: AppColors.grey400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        restaurant.deliveryTimeText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (restaurant.distance != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: const BoxDecoration(
                            color: AppColors.grey400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          Helpers.formatDistance(restaurant.distance!),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Delivery fee and total orders
                  Row(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
