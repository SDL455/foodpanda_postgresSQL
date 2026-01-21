import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

/// Model ສຳລັບ Menu Item
class MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });
}

/// Widget ສະແດງກຸ່ມເມນູ
class MenuSection extends StatelessWidget {
  final String title;
  final List<MenuItem> items;

  const MenuSection({
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
            return MenuItemWidget(item: item, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

/// Widget ສະແດງ Menu Item ແຕ່ລະອັນ
class MenuItemWidget extends StatelessWidget {
  final MenuItem item;
  final bool isLast;

  const MenuItemWidget({
    super.key,
    required this.item,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
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
            _buildIcon(),
            SizedBox(width: 12.w),
            Expanded(child: _buildTitle()),
            if (item.trailing != null) item.trailing!,
            if (item.trailing == null) _buildChevron(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
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
    );
  }

  Widget _buildTitle() {
    return Text(
      item.title,
      style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
    );
  }

  Widget _buildChevron() {
    return Icon(Icons.chevron_right, color: AppColors.grey400, size: 22.sp);
  }
}

/// Widget ສະແດງ Badge "ຢືນຢັນແລ້ວ"
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
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
}
