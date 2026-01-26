import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

/// Widget ສຳລັບສະແດງ logo ຂອງແອັບ
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Icon(Icons.restaurant_menu, size: 40.sp, color: AppColors.white),
      ),
    );
  }
}
