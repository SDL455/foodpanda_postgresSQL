import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';

/// Widget ສະແດງ Bottom Navigation Bar ຂອງ Rider
class RiderBottomNav extends StatelessWidget {
  final RiderController controller;

  const RiderBottomNav({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RiderNavItem(
                controller: controller,
                index: 0,
                icon: Icons.delivery_dining_outlined,
                activeIcon: Icons.delivery_dining,
                label: 'ສົ່ງອາຫານ',
              ),
              RiderNavItem(
                controller: controller,
                index: 1,
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet,
                label: 'ລາຍຮັບ',
              ),
              RiderNavItem(
                controller: controller,
                index: 2,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'ໂປຣໄຟລ໌',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget ສະແດງ Navigation Item ແຕ່ລະອັນ
class RiderNavItem extends StatelessWidget {
  final RiderController controller;
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const RiderNavItem({
    super.key,
    required this.controller,
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;

      return InkWell(
        onTap: () => controller.changePage(index),
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.primary : AppColors.grey500,
                size: 26.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
