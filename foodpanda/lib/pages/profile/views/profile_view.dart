import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_dialogs.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_stats_cards.dart';
import '../widgets/profile_user_card.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            ProfileUserCard(
              onEditTap: () => ProfileDialogs.showEditProfileDialog(controller),
            ),
            SizedBox(height: 16.h),
            const ProfileStatsCards(),
            SizedBox(height: 24.h),
            _buildAccountSection(),
            SizedBox(height: 16.h),
            _buildOtherSection(),
            SizedBox(height: 16.h),
            ProfileLogoutButton(
              onTap: () => ProfileDialogs.showLogoutConfirmation(controller),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildAccountSection() {
    return ProfileMenuSection(
      title: 'ບັນຊີ',
      items: [
        MenuItemData(
          icon: Icons.person_outline,
          title: AppStrings.editProfile,
          onTap: () => ProfileDialogs.showEditProfileDialog(controller),
        ),
        MenuItemData(
          icon: Icons.location_on_outlined,
          title: AppStrings.myAddresses,
          onTap: controller.goToAddresses,
        ),
        MenuItemData(
          icon: Icons.receipt_long_outlined,
          title: 'ປະຫວັດການສັ່ງຊື້',
          onTap: controller.goToOrderHistory,
        ),
        MenuItemData(
          icon: Icons.favorite_outline,
          title: AppStrings.favorites,
          onTap: controller.goToFavorites,
        ),
      ],
    );
  }

  Widget _buildOtherSection() {
    return ProfileMenuSection(
      title: 'ອື່ນໆ',
      items: [
        MenuItemData(
          icon: Icons.notifications_outlined,
          title: 'ການແຈ້ງເຕືອນ',
          onTap: controller.goToNotifications,
        ),
        MenuItemData(
          icon: Icons.help_outline,
          title: AppStrings.help,
          onTap: controller.goToHelp,
        ),
        MenuItemData(
          icon: Icons.info_outline,
          title: AppStrings.about,
          onTap: () => ProfileDialogs.showAboutDialog(),
        ),
      ],
    );
  }
}
