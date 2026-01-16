import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rider_controller.dart';
import '../controllers/rider_delivery_controller.dart';
import '../widgets/widgets.dart';
import 'rider_home_view.dart';
import 'rider_earnings_view.dart';
import 'rider_profile_view.dart';

class RiderMainView extends GetView<RiderController> {
  const RiderMainView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure delivery controller is available
    Get.put(RiderDeliveryController());

    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          RiderHomeView(),
          RiderEarningsView(),
          RiderProfileView(),
        ],
      ),
      bottomNavigationBar: Obx(() => RiderBottomNav(controller: controller)),
    );
  }
}
