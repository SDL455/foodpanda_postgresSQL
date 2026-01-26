import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

/// Widget ສຳລັບສະແດງ icon ຂອງ Google
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      margin: EdgeInsets.only(right: 8.w),
      child: Icon(Icons.g_mobiledata, size: 24.sp, color: AppColors.primary),
    );
  }
}
