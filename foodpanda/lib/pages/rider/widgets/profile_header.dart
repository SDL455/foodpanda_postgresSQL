import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';

/// Widget SliverAppBar ສະແດງ Header ໂປຣໄຟລ໌ຂອງ Rider
class ProfileHeader extends StatelessWidget {
  final RiderController controller;

  const ProfileHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                _buildAvatar(),
                SizedBox(height: 12.h),
                _buildName(),
                SizedBox(height: 4.h),
                _buildContact(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 3),
      ),
      child: CircleAvatar(
        radius: 45.r,
        backgroundColor: AppColors.white.withOpacity(0.2),
        child: Obx(
          () => controller.riderAvatar.value.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    controller.riderAvatar.value,
                    width: 90.r,
                    height: 90.r,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: 50.sp,
                  color: AppColors.white,
                ),
        ),
      ),
    );
  }

  Widget _buildName() {
    return Obx(
      () => Text(
        controller.riderName.value.isNotEmpty
            ? controller.riderName.value
            : 'Rider',
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildContact() {
    return Obx(
      () => Text(
        controller.riderPhone.value.isNotEmpty
            ? controller.riderPhone.value
            : controller.riderEmail.value,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}
