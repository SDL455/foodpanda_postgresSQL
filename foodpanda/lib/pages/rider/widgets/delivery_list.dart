import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/delivery_model.dart';
import '../controllers/rider_delivery_controller.dart';
import 'delivery_card.dart';

/// Widget ສະແດງລາຍການງານສົ່ງທັງໝົດ
class DeliveryList extends StatelessWidget {
  final RiderDeliveryController controller;

  const DeliveryList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<DeliveryModel> deliveries;
      switch (controller.selectedTab.value) {
        case 0:
          deliveries = controller.availableDeliveries;
          break;
        case 1:
          deliveries = controller.activeDeliveries;
          break;
        case 2:
          deliveries = controller.completedDeliveries;
          break;
        default:
          deliveries = [];
      }

      if (controller.isLoading.value && deliveries.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (deliveries.isEmpty) {
        return SliverFillRemaining(child: EmptyDeliveryState(
          tabIndex: controller.selectedTab.value,
        ));
      }

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Load more when reaching end
              if (index == deliveries.length - 1 && controller.canLoadMore) {
                controller.loadMore();
              }
              
              return DeliveryCard(
                delivery: deliveries[index],
                controller: controller,
              );
            },
            childCount: deliveries.length,
          ),
        ),
      );
    });
  }
}

/// Widget ສະແດງເມື່ອບໍ່ມີງານສົ່ງ
class EmptyDeliveryState extends StatelessWidget {
  final int tabIndex;
  
  const EmptyDeliveryState({super.key, this.tabIndex = 0});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;
    
    switch (tabIndex) {
      case 0:
        message = 'ບໍ່ມີງານສົ່ງໃໝ່';
        icon = Icons.delivery_dining_outlined;
        break;
      case 1:
        message = 'ບໍ່ມີງານສົ່ງທີ່ກຳລັງດຳເນີນ';
        icon = Icons.local_shipping_outlined;
        break;
      case 2:
        message = 'ຍັງບໍ່ມີປະຫວັດການສົ່ງ';
        icon = Icons.history;
        break;
      default:
        message = 'ບໍ່ມີງານສົ່ງ';
        icon = Icons.inbox_outlined;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.sp,
            color: AppColors.grey400,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            tabIndex == 0 ? 'ງານສົ່ງໃໝ່ຈະປະກົດຢູ່ນີ້' : '',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}
