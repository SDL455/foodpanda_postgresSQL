import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/cached_image.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.profile),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // User info card
            _buildUserCard(),
            SizedBox(height: 24.h),
            // Menu items
            _buildMenuSection(
              title: 'ບັນຊີ',
              items: [
                _MenuItemData(
                  icon: Icons.person_outline,
                  title: AppStrings.editProfile,
                  onTap: () {},
                ),
                _MenuItemData(
                  icon: Icons.location_on_outlined,
                  title: AppStrings.myAddresses,
                  onTap: () {},
                ),
                _MenuItemData(
                  icon: Icons.credit_card_outlined,
                  title: AppStrings.paymentMethods,
                  onTap: () {},
                ),
                _MenuItemData(
                  icon: Icons.favorite_outline,
                  title: AppStrings.favorites,
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildMenuSection(
              title: 'ອື່ນໆ',
              items: [
                _MenuItemData(
                  icon: Icons.settings_outlined,
                  title: AppStrings.settings,
                  onTap: () {},
                ),
                _MenuItemData(
                  icon: Icons.help_outline,
                  title: AppStrings.help,
                  onTap: () {},
                ),
                _MenuItemData(
                  icon: Icons.info_outline,
                  title: AppStrings.about,
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Logout button
            _buildLogoutButton(),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
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
            // Avatar
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: user?.avatar != null
                  ? ClipOval(
                      child: CachedImage(
                        imageUrl: user!.avatar!,
                        width: 70.w,
                        height: 70.w,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 40.sp,
                      color: AppColors.primary,
                    ),
            ),
            SizedBox(width: 16.w),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'ຜູ້ໃຊ້',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (user?.phone != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      user!.phone!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Edit button
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.edit,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItemData> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...items.map((item) => _buildMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItemData item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: AppColors.textPrimary,
              size: 22.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: controller.logout,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: AppColors.error,
                size: 22.sp,
              ),
              SizedBox(width: 16.w),
              Text(
                AppStrings.logout,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
