import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/restaurants_controller.dart';
import 'restaurant_card.dart';
import 'restaurant_shimmer_loading.dart';

class RestaurantList extends GetView<RestaurantsController> {
  const RestaurantList({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshRestaurants,
      color: AppColors.primary,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 200) {
            controller.loadMore();
          }
          return false;
        },
        child: Obx(() => ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.restaurants.length +
              (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            if (index >= controller.restaurants.length) {
              return const RestaurantLoadingItem();
            }
            final restaurant = controller.restaurants[index];
            return RestaurantCard(restaurant: restaurant);
          },
        )),
      ),
    );
  }
}
