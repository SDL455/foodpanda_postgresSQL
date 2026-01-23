import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_button.dart';

class CartCheckoutButton extends StatelessWidget {
  final double total;

  const CartCheckoutButton({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: '${AppStrings.checkout} • ${Helpers.formatCurrency(total)}',
          onPressed: () => Get.toNamed(AppRoutes.checkout),
        ),
      ),
    );
  }
}
