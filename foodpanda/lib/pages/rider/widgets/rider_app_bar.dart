import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';

/// SliverAppBar ສຳລັບໜ້າຫຼັກຂອງ Rider
class RiderAppBar extends StatelessWidget {
  final RiderController controller;

  const RiderAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
                      const NotificationButton(),
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
}

/// ປຸ່ມແຈ້ງເຕືອນ
class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
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
    );
  }
}
