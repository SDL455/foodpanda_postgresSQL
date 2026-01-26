import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// Widget ສຳລັບສະແດງລິ້ງລົງທະບຽນ (ສຳລັບລູກຄ້າເທົ່ານັ້ນ)
class RegisterLink extends GetView<AuthController> {
  const RegisterLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isRiderLogin.value
          ? const SizedBox.shrink()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.dontHaveAccount,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  child: Text(
                    AppStrings.register,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
