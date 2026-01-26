import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

/// Widget ສຳລັບເລືອກປະເພດຜູ້ໃຊ້ (ລູກຄ້າ ຫຼື Rider)
class UserTypeToggle extends GetView<AuthController> {
  const UserTypeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _ToggleOption(
                icon: Icons.person_outline,
                label: 'ລູກຄ້າ',
                isSelected: !controller.isRiderLogin.value,
                onTap: () {
                  if (controller.isRiderLogin.value) {
                    controller.toggleUserType();
                  }
                },
              ),
            ),
            Expanded(
              child: _ToggleOption(
                icon: Icons.delivery_dining,
                label: 'Rider',
                isSelected: controller.isRiderLogin.value,
                onTap: () {
                  if (!controller.isRiderLogin.value) {
                    controller.toggleUserType();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.grey600,
              size: 22.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
