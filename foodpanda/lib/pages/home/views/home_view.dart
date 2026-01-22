import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';
import 'home_app_bar.dart';
import 'home_promo_banners.dart';
import 'home_quick_categories.dart';
import 'home_section.dart';
import 'home_featured_restaurants.dart';
import 'home_all_foods.dart';
import 'home_shimmer_loading.dart';

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
              // Modern App Bar with gradient
              const HomeAppBar(),
              // Content
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverToBoxAdapter(child: HomeShimmerLoading());
                }
                return SliverList(
                  delegate: SliverChildListDelegate([
                    // Promotional Banners
                    const HomePromoBanners(),
                    SizedBox(height: 20.h),
                    // Quick Category Grid
                    const HomeQuickCategories(),
                    SizedBox(height: 24.h),
                    // Featured/Popular Restaurants
                    HomeSection(
                      title: AppStrings.featuredRestaurants,
                      onSeeAll: () => Get.toNamed(AppRoutes.restaurants),
                      child: const HomeFeaturedRestaurants(),
                    ),
                    SizedBox(height: 16.h),
                    // All Foods List
                    HomeSection(
                      title: AppStrings.allFoods,
                      onSeeAll: () => Get.toNamed(AppRoutes.foods),
                      child: const HomeAllFoods(),
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
}
