import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';
import '../controllers/rider_delivery_controller.dart';
import 'rider_delivery_detail_view.dart';

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
            _buildAppBar(),

            // Online Status Toggle
            SliverToBoxAdapter(child: _buildOnlineToggle()),

            // Stats Cards
            SliverToBoxAdapter(child: _buildStatsCards()),

            // Tab Bar
            SliverToBoxAdapter(child: _buildTabBar(deliveryController)),

            // Delivery List
            _buildDeliveryList(deliveryController),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundColor: AppColors.white.withOpacity(0.2),
                        child: Icon(
                          Icons.delivery_dining,
                          color: AppColors.white,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Text(
                                'ສະບາຍດີ, ${controller.riderName.value.isNotEmpty ? controller.riderName.value : 'Rider'}',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'ພ້ອມຮັບງານສົ່ງແລ້ວບໍ່?',
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.9),
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notifications
                      IconButton(
                        onPressed: () {},
                        icon: Stack(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: AppColors.white,
                              size: 28.sp,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineToggle() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: controller.isOnline.value
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.grey200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
                color: controller.isOnline.value
                    ? AppColors.success
                    : AppColors.grey500,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.isOnline.value ? 'ອອນລາຍ' : 'ອອບໄລນ໌',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: controller.isOnline.value
                          ? AppColors.success
                          : AppColors.grey600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    controller.isOnline.value
                        ? 'ກຳລັງຮັບງານສົ່ງອາຫານ'
                        : 'ກົດເພື່ອເລີ່ມຮັບງານ',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 1.2,
              child: Switch(
                value: controller.isOnline.value,
                onChanged: (_) => controller.toggleOnlineStatus(),
                activeColor: AppColors.success,
                activeTrackColor: AppColors.success.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_shipping,
              label: 'ສົ່ງວັນນີ້',
              value: controller.todayDeliveries,
              color: AppColors.info,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              icon: Icons.monetization_on,
              label: 'ລາຍຮັບວັນນີ້',
              value: controller.todayEarnings,
              isCurrency: true,
              color: AppColors.success,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star,
              label: 'ຄະແນນ',
              value: controller.rating,
              suffix: '/5',
              color: AppColors.ratingActive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required Rx value,
    bool isCurrency = false,
    String? suffix,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            String displayValue;
            if (isCurrency) {
              displayValue = '${(value.value as double).toStringAsFixed(0)}₭';
            } else if (value.value is double) {
              displayValue = '${value.value}${suffix ?? ''}';
            } else {
              displayValue = '${value.value}${suffix ?? ''}';
            }
            return Text(
              displayValue,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(RiderDeliveryController deliveryController) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: Obx(
        () => Row(
          children: [
            _buildTabItem(
              deliveryController,
              index: 0,
              label: 'ງານໃໝ່',
              count: deliveryController.availableDeliveries.length,
            ),
            SizedBox(width: 12.w),
            _buildTabItem(
              deliveryController,
              index: 1,
              label: 'ກຳລັງສົ່ງ',
              count: deliveryController.activeDeliveries.length,
            ),
            SizedBox(width: 12.w),
            _buildTabItem(
              deliveryController,
              index: 2,
              label: 'ສຳເລັດ',
              count: deliveryController.completedDeliveries.length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    RiderDeliveryController controller, {
    required int index,
    required String label,
    required int count,
  }) {
    final isSelected = controller.selectedTab.value == index;
    return Expanded(
      child: InkWell(
        onTap: () => controller.selectedTab.value = index,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey300,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withOpacity(0.2)
                      : AppColors.grey200,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryList(RiderDeliveryController deliveryController) {
    return Obx(() {
      List<DeliveryItem> deliveries;
      switch (deliveryController.selectedTab.value) {
        case 0:
          deliveries = deliveryController.availableDeliveries;
          break;
        case 1:
          deliveries = deliveryController.activeDeliveries;
          break;
        case 2:
          deliveries = deliveryController.completedDeliveries;
          break;
        default:
          deliveries = [];
      }

      if (deliveries.isEmpty) {
        return SliverFillRemaining(
          child: Center(
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
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildDeliveryCard(deliveries[index], deliveryController),
            childCount: deliveries.length,
          ),
        ),
      );
    });
  }

  Widget _buildDeliveryCard(
    DeliveryItem delivery,
    RiderDeliveryController deliveryController,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              Get.to(() => RiderDeliveryDetailView(delivery: delivery)),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '#${delivery.orderNo}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (delivery.distance != null)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14.sp,
                                color: AppColors.grey500,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                '${delivery.distance} km',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${delivery.deliveryFee.toString()}₭',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Store Info
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.store,
                        color: AppColors.warning,
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ຮ້ານ',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            delivery.storeName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Dotted Line
                Padding(
                  padding: EdgeInsets.only(left: 19.w),
                  child: Container(
                    width: 2,
                    height: 20.h,
                    color: AppColors.grey300,
                  ),
                ),

                // Customer Info
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.success,
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ລູກຄ້າ',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            delivery.customerName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            delivery.customerAddress,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Action Button
                if (delivery.status == DeliveryStatus.pending)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          deliveryController.acceptDelivery(delivery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'ຮັບງານນີ້',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
