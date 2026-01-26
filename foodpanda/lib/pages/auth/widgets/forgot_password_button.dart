import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';

/// Widget ສຳລັບປຸ່ມລືມລະຫັດຜ່ານ
class ForgotPasswordButton extends GetView<AuthController> {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: controller.forgotPassword,
        child: Text(
          AppStrings.forgotPassword,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
