import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/cached_image.dart';
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
              SizedBox(height: 20.h),
              _buildAvatarSection(controller),
              SizedBox(height: 24.h),
              _buildFullNameField(controller),
              SizedBox(height: 16.h),
              _buildPhoneField(controller),
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

  static Widget _buildAvatarSection(ProfileController controller) {
    return Center(
      child: Column(
        children: [
          Obx(() {
            final user = controller.user.value;
            final isUploading = controller.isUploadingAvatar.value;

            return Stack(
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: isUploading
                      ? Center(
                          child: SizedBox(
                            width: 40.w,
                            height: 40.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                        )
                      : user?.avatar != null && user!.avatar!.isNotEmpty
                          ? ClipOval(
                              child: CachedImage(
                                imageUrl:
                                    ApiConstants.getImageUrl(user.avatar),
                                width: 100.w,
                                height: 100.w,
                              ),
                            )
                          : Center(
                              child: Text(
                                user?.initials ?? 'U',
                                style: TextStyle(
                                  fontSize: 36.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                ),
                // Camera button overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showImagePickerOptions(controller),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 12.h),
          Text(
            'ກົດທີ່ຮູບເພື່ອປ່ຽນ',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  static void _showImagePickerOptions(ProfileController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'ເລືອກຮູບພາບ',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'ຄັງຮູບ',
                  color: Colors.blue,
                  onTap: () {
                    Get.back();
                    controller.pickAndUploadAvatar(
                      source: ImageSource.gallery,
                    );
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'ຖ່າຍຮູບ',
                  color: Colors.green,
                  onTap: () {
                    Get.back();
                    controller.pickAndUploadAvatar(
                      source: ImageSource.camera,
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  static Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
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
