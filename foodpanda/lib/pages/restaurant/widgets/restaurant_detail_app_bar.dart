import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/restaurant_model.dart';
import '../controllers/restaurant_detail_controller.dart';

class RestaurantDetailAppBar extends GetView<RestaurantDetailController> {
  final RestaurantModel restaurant;

  const RestaurantDetailAppBar({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      backgroundColor: AppColors.white,
      leading: const _BackButton(),
      actions: const [_FavoriteButton()],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Restaurant Image
            Image.network(
              restaurant.displayImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.grey200,
                child: Icon(
                  Icons.restaurant,
                  size: 80.sp,
                  color: AppColors.grey400,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            // Open/Close status badge
            Positioned(
              bottom: 16.h,
              left: 16.w,
              child: _StatusBadge(isActive: restaurant.isActive),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back Button Widget
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppColors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }
}

/// Favorite Button Widget
class _FavoriteButton extends GetView<RestaurantDetailController> {
  const _FavoriteButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Obx(() {
        final isFavorite = controller.isFavorite.value;
        final isLoading = controller.isFavoriteLoading.value;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: IconButton(
            icon: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
            onPressed: isLoading ? null : controller.toggleFavorite,
          ),
        );
      }),
    );
  }
}

/// Status Badge Widget (Open/Closed)
class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success : AppColors.error,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: AppColors.white,
            size: 14.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            isActive ? 'ເປີດໃຫ້ບໍລິການ' : 'ປິດແລ້ວ',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
