import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';
import '../controllers/rider_delivery_controller.dart';
import '../widgets/widgets.dart';

class RiderHomeView extends GetView<RiderController> {
  const RiderHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveryController = Get.find<RiderDeliveryController>();

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshData();
          await deliveryController.loadDeliveries();
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            RiderAppBar(controller: controller),

            // Online Status Toggle
            SliverToBoxAdapter(
              child: OnlineToggleCard(controller: controller),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: RiderStatsCards(controller: controller),
            ),

            // Tab Bar
            SliverToBoxAdapter(
              child: DeliveryTabBar(controller: deliveryController),
            ),

            // Delivery List
            DeliveryList(controller: deliveryController),
          ],
        ),
      ),
    );
  }
}
