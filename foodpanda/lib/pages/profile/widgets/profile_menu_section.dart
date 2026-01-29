import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

class MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<MenuItemData> items;

  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
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
          ...items.map((item) => _ProfileMenuItem(item: item)),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final MenuItemData item;

  const _ProfileMenuItem({required this.item});

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey400, size: 22.sp),
          ],
        ),
      ),
    );
  }
}

class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const ProfileLogoutButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(Icons.logout, color: AppColors.error, size: 22.sp),
              SizedBox(width: 16.w),
              Text(
                'ອອກຈາກລະບົບ',
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
