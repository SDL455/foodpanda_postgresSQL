import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

/// Widget ສະແດງ Chart ລາຍຮັບ 7 ມື້
class EarningsChart extends StatelessWidget {
  const EarningsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          SizedBox(height: 20.h),
          _buildBars(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'ລາຍຮັບ 7 ມື້ຜ່ານມາ',
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildBars() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        ChartBar(day: 'ຈ', percentage: 0.6),
        ChartBar(day: 'ອ', percentage: 0.8),
        ChartBar(day: 'ພ', percentage: 0.4),
        ChartBar(day: 'ພຫ', percentage: 0.9),
        ChartBar(day: 'ສ', percentage: 1.0),
        ChartBar(day: 'ສ', percentage: 0.7),
        ChartBar(day: 'ອາ', percentage: 0.5),
      ],
    );
  }
}

/// Widget ສະແດງແທ່ງ Chart ແຕ່ລະວັນ
class ChartBar extends StatelessWidget {
  final String day;
  final double percentage;

  const ChartBar({
    super.key,
    required this.day,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            Container(
              height: 100.h * percentage,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              day,
              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
