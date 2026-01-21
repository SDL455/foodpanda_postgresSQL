import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/food_detail_controller.dart';

class FoodDetailView extends GetView<FoodDetailController> {
  const FoodDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Obx(() {
        final food = controller.food.value;
        if (food == null && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (food == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: AppColors.grey400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'ບໍ່ພົບຂໍ້ມູນອາຫານ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Food Image with App Bar
                SliverAppBar(
                  expandedHeight: 280.h,
                  pinned: true,
                  backgroundColor: AppColors.white,
                  leading: _buildBackButton(),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          food.displayImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: AppColors.grey200,
                                child: Icon(
                                  Icons.fastfood,
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
                                AppColors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Content
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                    transform: Matrix4.translationValues(0, -20.h, 0),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food Name & Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (food.category != null) ...[
                                      SizedBox(height: 4.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: Text(
                                          food.category!.name,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                food.priceText,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          // Store Info
                          _buildStoreInfo(food),
                          SizedBox(height: 20.h),
                          // Description
                          if (food.description != null &&
                              food.description!.isNotEmpty) ...[
                            Text(
                              'ລາຍລະອຽດ',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              food.description!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                          // Variants
                          if (food.hasVariants) ...[
                            Text(
                              AppStrings.selectOptions,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ...food.availableVariants.map(
                              (variant) => _buildVariantItem(variant),
                            ),
                            SizedBox(height: 20.h),
                          ],
                          // Quantity Selector
                          Text(
                            AppStrings.quantity,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildQuantitySelector(),
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Bottom Add to Cart Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomButton(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBackButton() {
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

  Widget _buildStoreInfo(food) {
    return GestureDetector(
      onTap: () {
        // Navigate to store detail
        // Get.toNamed(AppRoutes.restaurantDetail, arguments: food.store);
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Store Logo
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: food.store.logo != null
                    ? Image.network(
                        food.store.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.store,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      )
                    : Icon(Icons.store, color: AppColors.primary, size: 24.sp),
              ),
            ),
            SizedBox(width: 12.w),
            // Store Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.fromStore}:',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    food.store.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.ratingActive,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        food.store.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
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
                        food.store.prepTimeText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey400, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantItem(variant) {
    return Obx(() {
      final isSelected = controller.isVariantSelected(variant.id);
      return GestureDetector(
        onTap: () => controller.toggleVariant(variant.id),
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : AppColors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: AppColors.white, size: 14.sp)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  variant.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (variant.priceDelta > 0)
                Text(
                  variant.priceDeltaText,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuantitySelector() {
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

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  '${AppStrings.addToCart} - ${controller.totalPriceText}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
