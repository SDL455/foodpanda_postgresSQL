import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/cached_image.dart';
import '../controllers/profile_controller.dart';

class ProfileUserCard extends GetView<ProfileController> {
  final VoidCallback onEditTap;

  const ProfileUserCard({
    super.key,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final user = controller.user.value;
        return Row(
          children: [
            _buildAvatar(user),
            SizedBox(width: 16.w),
            _buildUserInfo(user),
            _buildEditButton(),
          ],
        );
      }),
    );
  }

  Widget _buildAvatar(user) {
    return Container(
      width: 70.w,
      height: 70.w,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: user?.avatar != null && user!.avatar!.isNotEmpty
          ? ClipOval(
              child: CachedImage(
                imageUrl: ApiConstants.getImageUrl(user.avatar),
                width: 70.w,
                height: 70.w,
              ),
            )
          : Center(
              child: Text(
                user?.initials ?? 'U',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
    );
  }

  Widget _buildUserInfo(user) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user?.displayName ?? 'ຜູ້ໃຊ້',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          if (user?.email != null) ...[
            Text(
              user!.email!,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (user?.phone != null && user!.phone!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              user.phone!,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 4.h),
          _buildAuthProviderBadge(),
        ],
      ),
    );
  }

  Widget _buildAuthProviderBadge() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 2.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            controller.getAuthProviderText(),
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'ເຂົ້າຮ່ວມ: ${controller.getFormattedJoinDate()}',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.grey500,
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      onPressed: onEditTap,
      icon: Icon(Icons.edit, color: AppColors.primary, size: 22.sp),
    );
  }
}
