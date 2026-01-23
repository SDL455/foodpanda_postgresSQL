import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/restaurant_model.dart';

class RestaurantDetailInfo extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailInfo({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Rating Row
          _buildNameAndRating(),
          SizedBox(height: 12.h),

          // Description
          if (restaurant.description != null &&
              restaurant.description!.isNotEmpty) ...[
            _buildDescription(),
            SizedBox(height: 12.h),
          ],

          // Address
          if (restaurant.address != null && restaurant.address!.isNotEmpty) ...[
            _buildAddress(),
            SizedBox(height: 16.h),
          ],

          // Info Cards Row
          _buildInfoCardsRow(),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildNameAndRating() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            restaurant.name,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _RatingBadge(
          rating: restaurant.rating,
          reviewCount: restaurant.reviewCount,
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      restaurant.description!,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAddress() {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16.sp, color: AppColors.grey500),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            restaurant.address!,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCardsRow() {
    return Row(
      children: [
        InfoCard(
          icon: Icons.access_time,
          title: 'ເວລາສົ່ງ',
          value: restaurant.deliveryTimeText,
        ),
        SizedBox(width: 12.w),
        InfoCard(
          icon: Icons.delivery_dining,
          title: 'ຄ່າສົ່ງ',
          value: restaurant.deliveryFeeText,
        ),
        SizedBox(width: 12.w),
        InfoCard(
          icon: Icons.shopping_bag_outlined,
          title: 'ສັ່ງຂັ້ນຕ່ຳ',
          value: restaurant.minOrderAmount > 0
              ? '₭${_formatNumber(restaurant.minOrderAmount)}'
              : 'ບໍ່ມີ',
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// Rating Badge Widget
class _RatingBadge extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _RatingBadge({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.ratingActive.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: AppColors.ratingActive, size: 18.sp),
          SizedBox(width: 4.w),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            '($reviewCount)',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Info Card Widget (Delivery Time, Fee, Min Order)
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22.sp),
            SizedBox(height: 6.h),
            Text(
              title,
              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
