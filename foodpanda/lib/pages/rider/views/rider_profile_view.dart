import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';
import '../widgets/widgets.dart';

class RiderProfileView extends GetView<RiderController> {
  const RiderProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          ProfileHeader(controller: controller),

          // Menu Items
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Stats Card
                  const ProfileStatsCard(),

                  SizedBox(height: 16.h),

                  // Menu Section - Account
                  MenuSection(
                    title: 'ບັນຊີ',
                    items: [
                      MenuItem(
                        icon: Icons.person_outline,
                        title: 'ຂໍ້ມູນສ່ວນຕົວ',
                        onTap: () {},
                      ),
                      MenuItem(
                        icon: Icons.verified_user_outlined,
                        title: 'ການຢືນຢັນຕົວຕົນ',
                        onTap: () {},
                        trailing: const VerifiedBadge(),
                      ),
                      MenuItem(
                        icon: Icons.two_wheeler_outlined,
                        title: 'ຂໍ້ມູນພາຫະນະ',
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Menu Section - Finance
                  MenuSection(
                    title: 'ການເງິນ',
                    items: [
                      MenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'ກະເປົາເງິນ',
                        onTap: () {},
                      ),
                      MenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: 'ປະຫວັດການສົ່ງ',
                        onTap: () {},
                      ),
                      MenuItem(
                        icon: Icons.account_balance_outlined,
                        title: 'ບັນຊີທະນາຄານ',
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Menu Section - Settings
                  MenuSection(
                    title: 'ການຕັ້ງຄ່າ',
                    items: [
                      MenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'ການແຈ້ງເຕືອນ',
                        onTap: () {},
                      ),
                      MenuItem(
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
                      MenuItem(
                        icon: Icons.help_outline,
                        title: 'ຊ່ວຍເຫຼືອ',
                        onTap: () {},
                      ),
                      MenuItem(
                        icon: Icons.info_outline,
                        title: 'ກ່ຽວກັບແອັບ',
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Logout Button
                  _buildLogoutButton(context),

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

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => showLogoutDialog(context, controller),
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
    );
  }
}
