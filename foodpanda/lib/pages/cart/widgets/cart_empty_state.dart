import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_button.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 24.h),
          Text(
            AppStrings.emptyCart,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ເລືອກອາຫານຈາກຮ້ານທີ່ທ່ານມັກ',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 32.h),
          CustomButton(
            text: 'ເລີ່ມສັ່ງອາຫານ',
            onPressed: () => Get.offAllNamed(AppRoutes.main),
            width: 200.w,
          ),
        ],
      ),
    );
  }
}
