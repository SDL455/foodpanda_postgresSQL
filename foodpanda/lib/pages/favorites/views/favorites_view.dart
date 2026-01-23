import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/favorite_model.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/shimmer_loading.dart';
import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(AppStrings.favorites)),
      body: RefreshIndicator(
        onRefresh: controller.refreshFavorites,
        color: AppColors.primary,
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading();
          }

          if (controller.favorites.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.favorites.length,
            itemBuilder: (context, index) {
              return _buildFavoriteCard(controller.favorites[index]);
            },
          );
        }),
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteModel favorite) {
    final restaurant = favorite.restaurant;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: InkWell(
        onTap: restaurant != null
            ? () => controller.goToRestaurant(restaurant)
            : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Restaurant image
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: CachedImage(
                  imageUrl: restaurant?.displayImage ?? '',
                  width: 80.w,
                  height: 80.w,
                ),
              ),
              SizedBox(width: 12.w),
              // Restaurant info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant?.name ?? 'ຮ້ານອາຫານ',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    if (restaurant != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            restaurant.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '(${restaurant.reviewCount})',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            color: AppColors.grey500,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${restaurant.estimatedPrepTime} ນາທີ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                              color: AppColors.grey400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            restaurant.isActive ? 'ເປີດຢູ່' : 'ປິດແລ້ວ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: restaurant.isActive
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Remove button
              IconButton(
                onPressed: () =>
                    controller.removeFromFavorites(favorite.storeId),
                icon: Icon(Icons.favorite, color: AppColors.error, size: 24.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 100.sp, color: AppColors.grey300),
          SizedBox(height: 24.h),
          Text(
            'ຍັງບໍ່ມີຮ້ານໂປດ',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ກົດໄອຄອນຫົວໃຈເພື່ອເພີ່ມຮ້ານທີ່ມັກ',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ShimmerLoading(
        child: Column(
          children: List.generate(
            4,
            (index) => Container(
              height: 100.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
