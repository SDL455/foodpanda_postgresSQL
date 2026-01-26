import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

/// Widget ສະແດງເມື່ອບໍ່ມີທີ່ຢູ່
class AddressEmptyState extends StatelessWidget {
  const AddressEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 100.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 24.h),
          Text(
            'ຍັງບໍ່ມີທີ່ຢູ່',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ເພີ່ມທີ່ຢູ່ເພື່ອຄວາມສະດວກໃນການສັ່ງອາຫານ',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
