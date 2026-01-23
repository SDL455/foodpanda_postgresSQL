import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

class CartQuantityControls extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const CartQuantityControls({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onDecrease,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(Icons.remove, size: 16.sp, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              '$quantity',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
          InkWell(
            onTap: onIncrease,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(Icons.add, size: 16.sp, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
