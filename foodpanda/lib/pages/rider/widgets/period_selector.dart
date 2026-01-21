import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';

/// Widget ສະແດງຕົວເລືອກໄລຍະເວລາ
class PeriodSelector extends StatelessWidget {
  final RxInt selectedPeriod;
  final List<String> periods;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    this.periods = const ['ວັນນີ້', 'ອາທິດ', 'ເດືອນ', 'ທັງໝົດ'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Obx(
        () => Row(
          children: periods.asMap().entries.map((entry) {
            final isSelected = selectedPeriod.value == entry.key;
            return Expanded(
              child: PeriodItem(
                label: entry.value,
                isSelected: isSelected,
                onTap: () => selectedPeriod.value = entry.key,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Widget ສະແດງ Period Item ແຕ່ລະອັນ
class PeriodItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PeriodItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
