import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_delivery_controller.dart';
import 'delivery_card.dart';

/// Widget ສະແດງລາຍການງານສົ່ງທັງໝົດ
class DeliveryList extends StatelessWidget {
  final RiderDeliveryController controller;

  const DeliveryList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<DeliveryItem> deliveries;
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

      if (deliveries.isEmpty) {
        return SliverFillRemaining(child: EmptyDeliveryState());
      }

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => DeliveryCard(
              delivery: deliveries[index],
              controller: controller,
            ),
            childCount: deliveries.length,
          ),
        ),
      );
    });
  }
}

/// Widget ສະແດງເມື່ອບໍ່ມີງານສົ່ງ
class EmptyDeliveryState extends StatelessWidget {
  const EmptyDeliveryState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64.sp,
            color: AppColors.grey400,
          ),
          SizedBox(height: 16.h),
          Text(
            'ບໍ່ມີງານສົ່ງ',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
