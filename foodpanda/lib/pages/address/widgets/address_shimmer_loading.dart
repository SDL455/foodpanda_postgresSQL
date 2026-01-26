import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/shimmer_loading.dart';

/// Widget ສະແດງ shimmer loading ສຳລັບ address list
class AddressShimmerLoading extends StatelessWidget {
  final int itemCount;

  const AddressShimmerLoading({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ShimmerLoading(
        child: Column(
          children: List.generate(
            itemCount,
            (index) => Container(
              height: 100.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
