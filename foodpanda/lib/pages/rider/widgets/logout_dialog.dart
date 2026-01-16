import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';

/// Function ສຳລັບສະແດງ Dialog ຢືນຢັນການອອກຈາກລະບົບ
void showLogoutDialog(BuildContext context, RiderController controller) {
  showDialog(
    context: context,
    builder: (context) => LogoutDialog(controller: controller),
  );
}

/// Widget Dialog ຢືນຢັນການອອກຈາກລະບົບ
class LogoutDialog extends StatelessWidget {
  final RiderController controller;

  const LogoutDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Text(
        'ອອກຈາກລະບົບ',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?',
        style: TextStyle(fontSize: 14.sp),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'ຍົກເລີກ',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            controller.logout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'ອອກຈາກລະບົບ',
            style: TextStyle(fontSize: 14.sp, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
