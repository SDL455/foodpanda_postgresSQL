import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/restaurant_card.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/shimmer_loading.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(),
              // Search Bar
              _buildSearchBar(),
              // Content
              Obx(() {
                if (controller.isLoading.value) {
                  return SliverToBoxAdapter(child: _buildShimmerLoading());
                }
                return SliverList(
                  delegate: SliverChildListDelegate([
                    // Categories
                    _buildCategories(),
                    // Popular Restaurants
                    _buildSection(
                      title: AppStrings.popularRestaurants,
                      onSeeAll: () => Get.toNamed(AppRoutes.restaurants),
                      child: _buildPopularRestaurants(),
                    ),
                    // Nearby Restaurants
                    _buildSection(
                      title: AppStrings.nearbyRestaurants,
                      onSeeAll: () => Get.toNamed(AppRoutes.restaurants),
                      child: _buildNearbyRestaurants(),
                    ),
                    SizedBox(height: 100.h),
                  ]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      toolbarHeight: 70.h,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.deliverTo,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 18.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Obx(() => Text(
                      controller.currentAddress.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
              Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textPrimary, size: 20.sp),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.white,
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.search),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.textHint, size: 22.sp),
                SizedBox(width: 12.w),
                Text(
                  AppStrings.searchHint,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              AppStrings.categories,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 100.h,
            child: Obx(() => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: controller.categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return Obx(() => CategoryChip(
                          category: category,
                          isSelected:
                              controller.selectedCategoryId.value == category.id,
                          onTap: () => controller.selectCategory(category.id),
                        ));
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onSeeAll,
    required Widget child,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    AppStrings.seeAll,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildPopularRestaurants() {
    return SizedBox(
      height: 240.h,
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: controller.popularRestaurants.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final restaurant = controller.popularRestaurants[index];
              return RestaurantCard(
                restaurant: restaurant,
                onTap: () => Get.toNamed(
                  AppRoutes.restaurantDetail,
                  arguments: restaurant,
                ),
              );
            },
          )),
    );
  }

  Widget _buildNearbyRestaurants() {
    return Obx(() => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: controller.nearbyRestaurants.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final restaurant = controller.nearbyRestaurants[index];
            return RestaurantCard(
              restaurant: restaurant,
              isHorizontal: true,
              onTap: () => Get.toNamed(
                AppRoutes.restaurantDetail,
                arguments: restaurant,
              ),
            );
          },
        ));
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories shimmer
          ShimmerLoading(
            child: Row(
              children: List.generate(
                4,
                (index) => Container(
                  width: 80.w,
                  height: 100.h,
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          // Restaurant cards shimmer
          ShimmerLoading(
            child: Column(
              children: List.generate(
                3,
                (index) => Container(
                  height: 120.h,
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
