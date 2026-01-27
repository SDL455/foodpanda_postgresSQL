import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/profile_controller.dart';

class ProfileDialogs {
  static void showEditProfileDialog(ProfileController controller) {
    controller.loadUserData();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogHeader(),
              SizedBox(height: 16.h),
              _buildFullNameField(controller),
              SizedBox(height: 16.h),
              _buildPhoneField(controller),
              SizedBox(height: 16.h),
              _buildAvatarField(controller),
              SizedBox(height: 24.h),
              _buildSaveButton(controller),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildDialogHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ແກ້ໄຂໂປຣໄຟລ໌',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  static Widget _buildFullNameField(ProfileController controller) {
    return TextField(
      controller: controller.fullNameController,
      decoration: InputDecoration(
        labelText: 'ຊື່-ນາມສະກຸນ',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  static Widget _buildPhoneField(ProfileController controller) {
    return TextField(
      controller: controller.phoneController,
      decoration: InputDecoration(
        labelText: 'ເບີໂທ',
        prefixIcon: const Icon(Icons.phone_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  static Widget _buildAvatarField(ProfileController controller) {
    return TextField(
      controller: controller.avatarController,
      decoration: InputDecoration(
        labelText: 'URL ຮູບໂປຣໄຟລ໌',
        prefixIcon: const Icon(Icons.image_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  static Widget _buildSaveButton(ProfileController controller) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          onPressed:
              controller.isUpdating.value ? null : controller.updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: controller.isUpdating.value
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  'ບັນທຶກ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  static void showAboutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.restaurant, color: AppColors.primary, size: 28.sp),
            SizedBox(width: 8.w),
            const Text('Foodpanda Clone'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            Text(
              'ແອັບສັ່ງອາຫານອອນໄລນ໌',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            Text(
              'ພັດທະນາໂດຍ:',
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
            ),
            Text('Nuxt 3 + Flutter', style: TextStyle(fontSize: 14.sp)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ປິດ')),
        ],
      ),
    );
  }

  static void showLogoutConfirmation(ProfileController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('ອອກຈາກລະບົບ'),
        content: const Text('ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ຍົກເລີກ'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'ອອກຈາກລະບົບ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
