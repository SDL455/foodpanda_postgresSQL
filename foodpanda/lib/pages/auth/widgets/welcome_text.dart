import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

/// Widget ສຳລັບສະແດງຂໍ້ຄວາມຕ້ອນຮັບ
class WelcomeText extends GetView<AuthController> {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => Text(
            controller.isRiderLogin.value
                ? 'ຍິນດີຕ້ອນຮັບ Rider!'
                : 'ຍິນດີຕ້ອນຮັບກັບຄືນ!',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Text(
            controller.isRiderLogin.value
                ? 'ເຂົ້າສູ່ລະບົບເພື່ອຮັບງານສົ່ງ'
                : 'ເຂົ້າສູ່ລະບົບເພື່ອສັ່ງອາຫານ',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
