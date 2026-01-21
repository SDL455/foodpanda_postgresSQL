import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

/// Widget ສະແດງສະຖິຕິຂອງ Rider ໃນໜ້າໂປຣໄຟລ໌
class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ProfileStatItem(
              icon: Icons.star,
              value: '4.8',
              label: 'ຄະແນນ',
              color: AppColors.ratingActive,
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: ProfileStatItem(
              icon: Icons.local_shipping,
              value: '1,234',
              label: 'ສົ່ງແລ້ວ',
              color: AppColors.info,
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: ProfileStatItem(
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

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 60.h, color: AppColors.grey200);
  }
}

/// Widget ສະແດງລາຍການສະຖິຕິແຕ່ລະອັນ
class ProfileStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const ProfileStatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}
