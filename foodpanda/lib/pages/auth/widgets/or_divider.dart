import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Widget divider ສຳລັບແຍກສ່ວນຕ່າງໆ ພ້ອມຂໍ້ຄວາມ "ຫຼືສືບຕໍ່ດ້ວຍ"
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.grey300)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            AppStrings.orContinueWith,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
          ),
        ),
        Expanded(child: Divider(color: AppColors.grey300)),
      ],
    );
  }
}
