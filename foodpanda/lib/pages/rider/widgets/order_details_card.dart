import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

/// Widget ສະແດງລາຍລະອຽດຄຳສັ່ງຊື້
class OrderDetailsCard extends StatelessWidget {
  final double totalAmount;
  final double deliveryFee;

  const OrderDetailsCard({
    super.key,
    required this.totalAmount,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ລາຍລະອຽດ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          DetailRow(label: 'ມູນຄ່າອາຫານ', value: '$totalAmount₭'),
          DetailRow(label: 'ຄ່າຈັດສົ່ງ', value: '$deliveryFee₭'),
          Divider(height: 24.h),
          DetailRow(
            label: 'ລາຍຮັບທ່ານ',
            value: '$deliveryFee₭',
            isHighlight: true,
          ),
        ],
      ),
    );
  }
}

/// Widget ສະແດງແຖວຂໍ້ມູນລາຍລະອຽດ
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: isHighlight
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: isHighlight ? AppColors.success : AppColors.textPrimary,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
