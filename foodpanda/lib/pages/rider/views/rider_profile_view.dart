import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';

class RiderProfileView extends GetView<RiderController> {
  const RiderProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          _buildProfileHeader(),

          // Menu Items
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Stats Card
                  _buildStatsCard(),

                  SizedBox(height: 16.h),

                  // Menu Section
                  _buildMenuSection(
                    title: 'ບັນຊີ',
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline,
                        title: 'ຂໍ້ມູນສ່ວນຕົວ',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.verified_user_outlined,
                        title: 'ການຢືນຢັນຕົວຕົນ',
                        onTap: () {},
                        trailing: _buildVerifiedBadge(),
                      ),
                      _MenuItem(
                        icon: Icons.two_wheeler_outlined,
                        title: 'ຂໍ້ມູນພາຫະນະ',
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  _buildMenuSection(
                    title: 'ການເງິນ',
                    items: [
                      _MenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'ກະເປົາເງິນ',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: 'ປະຫວັດການສົ່ງ',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.account_balance_outlined,
                        title: 'ບັນຊີທະນາຄານ',
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  _buildMenuSection(
                    title: 'ການຕັ້ງຄ່າ',
                    items: [
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'ການແຈ້ງເຕືອນ',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.language_outlined,
                        title: 'ພາສາ',
                        onTap: () {},
                        trailing: Text(
                          'ລາວ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline,
                        title: 'ຊ່ວຍເຫຼືອ',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.info_outline,
                        title: 'ກ່ຽວກັບແອັບ',
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: Icon(
                        Icons.logout,
                        color: AppColors.error,
                        size: 20.sp,
                      ),
                      label: Text(
                        'ອອກຈາກລະບົບ',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Version
                  Text(
                    'ເວີຊັ່ນ 1.0.0',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textHint,
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
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
                // Avatar
                Container(
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
                ),
                SizedBox(height: 12.h),
                // Name
                Obx(
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
                ),
                SizedBox(height: 4.h),
                // Phone
                Obx(
                  () => Text(
                    controller.riderPhone.value.isNotEmpty
                        ? controller.riderPhone.value
                        : controller.riderEmail.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.white.withOpacity(0.9),
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

  Widget _buildStatsCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.star,
              value: '4.8',
              label: 'ຄະແນນ',
              color: AppColors.ratingActive,
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.local_shipping,
              value: '1,234',
              label: 'ສົ່ງແລ້ວ',
              color: AppColors.info,
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.calendar_today,
              value: '98%',
              label: 'ຕົງເວລາ',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 60.h, color: AppColors.grey200);
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == items.length - 1;
            return _buildMenuItem(item, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item, bool isLast) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: AppColors.grey100)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                item.icon,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
              ),
            ),
            if (item.trailing != null) item.trailing!,
            if (item.trailing == null)
              Icon(Icons.chevron_right, color: AppColors.grey400, size: 22.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: AppColors.success, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            'ຢືນຢັນແລ້ວ',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'ອອກຈາກລະບົບ',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ຍົກເລີກ',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'ອອກຈາກລະບົບ',
              style: TextStyle(fontSize: 14.sp, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });
}
