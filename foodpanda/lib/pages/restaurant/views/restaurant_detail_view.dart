import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/restaurant_detail_controller.dart';
import '../widgets/restaurant_detail_app_bar.dart';
import '../widgets/restaurant_detail_info.dart';
import '../widgets/restaurant_detail_categories.dart';
import '../widgets/restaurant_detail_food_list.dart';

class RestaurantDetailView extends GetView<RestaurantDetailController> {
  const RestaurantDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Obx(() {
        final restaurant = controller.restaurant.value;

        // Loading state
        if (restaurant == null && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (restaurant == null) {
          return _buildErrorState();
        }

        // Success state
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              // Header with Image
              RestaurantDetailAppBar(restaurant: restaurant),

              // Restaurant Info Section
              SliverToBoxAdapter(
                child: RestaurantDetailInfo(restaurant: restaurant),
              ),

              // Category Tabs (Sticky)
              SliverPersistentHeader(
                pinned: true,
                delegate: CategoryTabDelegate(
                  child: const RestaurantDetailCategories(),
                ),
              ),

              // Food List
              const RestaurantDetailFoodList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.grey400),
          SizedBox(height: 16.h),
          Text(
            'ບໍ່ພົບຂໍ້ມູນຮ້ານອາຫານ',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('ກັບຄືນ'),
          ),
        ],
      ),
    );
  }
}
