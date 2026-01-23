import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
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
        actions: [
          IconButton(
            onPressed: controller.refreshUserData,
            icon: Obx(
              () => controller.isLoading.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // User info card
            _buildUserCard(),
            SizedBox(height: 16.h),
            // Stats cards
            _buildStatsCards(),
            SizedBox(height: 24.h),
            // Menu items - Account section
            _buildMenuSection(
              title: 'ບັນຊີ',
              items: [
                _MenuItemData(
                  icon: Icons.person_outline,
                  title: AppStrings.editProfile,
                  onTap: () => _showEditProfileDialog(),
                ),
                _MenuItemData(
                  icon: Icons.location_on_outlined,
                  title: AppStrings.myAddresses,
                  onTap: controller.goToAddresses,
                ),
                _MenuItemData(
                  icon: Icons.receipt_long_outlined,
                  title: 'ປະຫວັດການສັ່ງຊື້',
                  onTap: controller.goToOrderHistory,
                ),
                _MenuItemData(
                  icon: Icons.favorite_outline,
                  title: AppStrings.favorites,
                  onTap: controller.goToFavorites,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Menu items - Other section
            _buildMenuSection(
              title: 'ອື່ນໆ',
              items: [
                _MenuItemData(
                  icon: Icons.notifications_outlined,
                  title: 'ການແຈ້ງເຕືອນ',
                  onTap: controller.goToNotifications,
                ),
                _MenuItemData(
                  icon: Icons.help_outline,
                  title: AppStrings.help,
                  onTap: controller.goToHelp,
                ),
                _MenuItemData(
                  icon: Icons.info_outline,
                  title: AppStrings.about,
                  onTap: () => _showAboutDialog(),
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
            ),
            SizedBox(width: 16.w),
            // User info
            Expanded(
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
                  Row(
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
                  ),
                ],
              ),
            ),
            // Edit button
            IconButton(
              onPressed: () => _showEditProfileDialog(),
              icon: Icon(Icons.edit, color: AppColors.primary, size: 22.sp),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatsCards() {
    return Obx(() {
      final user = controller.user.value;
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.shopping_bag_outlined,
              value: '${user?.totalOrders ?? 0}',
              label: 'ຄຳສັ່ງຊື້',
              color: AppColors.success,
              onTap: controller.goToOrderHistory,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              icon: Icons.favorite_outline,
              value: '${user?.totalFavorites ?? 0}',
              label: 'ຮ້ານທີ່ມັກ',
              color: AppColors.error,
              onTap: controller.goToFavorites,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star_outline,
              value: '${user?.totalReviews ?? 0}',
              label: 'ລີວິວ',
              color: AppColors.warning,
              onTap: () {}, // TODO: Navigate to reviews
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    // Re-init form controllers with current values
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
              Row(
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
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller.fullNameController,
                decoration: InputDecoration(
                  labelText: 'ຊື່-ນາມສະກຸນ',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller.phoneController,
                decoration: InputDecoration(
                  labelText: 'ເບີໂທ',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller.avatarController,
                decoration: InputDecoration(
                  labelText: 'URL ຮູບໂປຣໄຟລ໌',
                  prefixIcon: const Icon(Icons.image_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isUpdating.value
                        ? null
                        : controller.updateProfile,
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
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAboutDialog() {
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
            Icon(item.icon, color: AppColors.textPrimary, size: 22.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey400, size: 22.sp),
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
        onTap: () => _showLogoutConfirmation(),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(Icons.logout, color: AppColors.error, size: 22.sp),
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

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('ອອກຈາກລະບົບ'),
        content: const Text('ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ຍົກເລີກ')),
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

class _MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItemData({required this.icon, required this.title, required this.onTap});
}
