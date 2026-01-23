import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/food_detail_controller.dart';
import '../widgets/food_detail_back_button.dart';
import '../widgets/food_detail_bookmark_button.dart';
import '../widgets/food_detail_bottom_button.dart';
import '../widgets/food_quantity_selector.dart';
import '../widgets/food_store_info_card.dart';
import '../widgets/food_variant_item.dart';

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
                  leading: const FoodDetailBackButton(),
                  actions: const [FoodDetailBookmarkButton()],
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
                          _buildFoodHeader(food),
                          SizedBox(height: 16.h),
                          // Store Info
                          FoodStoreInfoCard(
                            food: food,
                            onTap: () {
                              // Navigate to store detail
                              // Get.toNamed(AppRoutes.restaurantDetail, arguments: food.store);
                            },
                          ),
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
                              (variant) => Obx(
                                () => FoodVariantItem(
                                  variant: variant,
                                  isSelected: controller.isVariantSelected(
                                    variant.id,
                                  ),
                                  onTap: () =>
                                      controller.toggleVariant(variant.id),
                                ),
                              ),
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
                          const FoodQuantitySelector(),
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Bottom Add to Cart Button
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FoodDetailBottomButton(),
            ),
          ],
        );
      }),
    );
  }

  /// Food header with name, category, and price
  /// ບໍ່ແຍກເປັນ widget ເພາະມັນເປັນ UI ທີ່ສະເພາະຂອງໜ້ານີ້ ແລະ ບໍ່ໄດ້ reuse
  Widget _buildFoodHeader(food) {
    return Row(
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
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6.r),
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
    );
  }
}
