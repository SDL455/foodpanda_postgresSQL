import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/food_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/restaurant_detail_controller.dart';

/// Food List Sliver Widget
class RestaurantDetailFoodList extends GetView<RestaurantDetailController> {
  const RestaurantDetailFoodList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final foods = controller.filteredFoods;

      if (controller.isLoading.value && foods.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (foods.isEmpty) {
        return const SliverFillRemaining(child: _EmptyFoodList());
      }

      return SliverPadding(
        padding: EdgeInsets.all(16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => FoodItemCard(food: foods[index]),
            childCount: foods.length,
          ),
        ),
      );
    });
  }
}

/// Empty Food List Widget
class _EmptyFoodList extends StatelessWidget {
  const _EmptyFoodList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64.sp, color: AppColors.grey400),
          SizedBox(height: 16.h),
          Text(
            'ບໍ່ມີເມນູອາຫານ',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Food Item Card Widget
class FoodItemCard extends StatelessWidget {
  final FoodModel food;

  const FoodItemCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.foodDetail, arguments: food),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
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
            // Food Image
            _FoodImage(imageUrl: food.displayImage),
            SizedBox(width: 12.w),
            // Food Info
            Expanded(child: _FoodInfo(food: food)),
          ],
        ),
      ),
    );
  }
}

/// Food Image Widget
class _FoodImage extends StatelessWidget {
  final String imageUrl;

  const _FoodImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Image.network(
        imageUrl,
        width: 90.w,
        height: 90.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 90.w,
          height: 90.w,
          color: AppColors.grey200,
          child: Icon(Icons.fastfood, color: AppColors.grey400, size: 32.sp),
        ),
      ),
    );
  }
}

/// Food Info Widget
class _FoodInfo extends StatelessWidget {
  final FoodModel food;

  const _FoodInfo({required this.food});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food Name
        Text(
          food.name,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // Description
        if (food.description != null && food.description!.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            food.description!,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(height: 8.h),
        // Price and Add Button Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              food.priceText,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            _AvailabilityBadge(isAvailable: food.isAvailable),
          ],
        ),
      ],
    );
  }
}

/// Availability Badge Widget (Add button or "Sold out" badge)
class _AvailabilityBadge extends StatelessWidget {
  final bool isAvailable;

  const _AvailabilityBadge({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    if (!isAvailable) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          'ໝົດແລ້ວ',
          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.add, color: AppColors.primary, size: 18.sp),
    );
  }
}
