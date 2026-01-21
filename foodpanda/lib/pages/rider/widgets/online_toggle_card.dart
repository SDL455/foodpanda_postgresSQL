import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';

/// Widget ສະແດງສະຖານະ Online/Offline ແລະ ປຸ່ມ Toggle
class OnlineToggleCard extends StatelessWidget {
  final RiderController controller;

  const OnlineToggleCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
            _buildStatusIcon(),
            SizedBox(width: 16.w),
            Expanded(child: _buildStatusText()),
            _buildToggleSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
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
    );
  }

  Widget _buildStatusText() {
    return Column(
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
          style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildToggleSwitch() {
    return Transform.scale(
      scale: 1.2,
      child: Switch(
        value: controller.isOnline.value,
        onChanged: (_) => controller.toggleOnlineStatus(),
        activeColor: AppColors.success,
        activeTrackColor: AppColors.success.withOpacity(0.3),
      ),
    );
  }
}
