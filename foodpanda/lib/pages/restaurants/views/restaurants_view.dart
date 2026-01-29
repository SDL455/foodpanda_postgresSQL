import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/restaurants_controller.dart';
import '../widgets/restaurant_search_bar.dart';
import '../widgets/restaurant_empty_state.dart';
import '../widgets/restaurant_shimmer_loading.dart';
import '../widgets/restaurant_list.dart';

class RestaurantsView extends GetView<RestaurantsController> {
  const RestaurantsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.allRestaurants,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          const RestaurantSearchBar(),
          // Restaurant list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.restaurants.isEmpty) {
                return const RestaurantShimmerLoading();
              }

              if (controller.restaurants.isEmpty) {
                return const RestaurantEmptyState();
              }

              return const RestaurantList();
            }),
          ),
        ],
      ),
    );
  }
}
