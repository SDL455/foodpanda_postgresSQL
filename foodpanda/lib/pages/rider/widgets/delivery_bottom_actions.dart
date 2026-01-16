import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_delivery_controller.dart';

/// Widget ປຸ່ມກົດຢູ່ລຸ່ມສຳລັບອັບເດດສະຖານະການສົ່ງ
class DeliveryBottomActions extends StatelessWidget {
  final DeliveryItem delivery;
  final RiderDeliveryController controller;

  const DeliveryBottomActions({
    super.key,
    required this.delivery,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (delivery.status == DeliveryStatus.delivered) {
      return const SizedBox.shrink();
    }

    String buttonText;
    DeliveryStatus nextStatus;

    switch (delivery.status) {
      case DeliveryStatus.pending:
        buttonText = 'ຮັບງານນີ້';
        nextStatus = DeliveryStatus.accepted;
        break;
      case DeliveryStatus.accepted:
        buttonText = 'ຮັບອາຫານແລ້ວ';
        nextStatus = DeliveryStatus.pickedUp;
        break;
      case DeliveryStatus.pickedUp:
        buttonText = 'ເລີ່ມສົ່ງ';
        nextStatus = DeliveryStatus.delivering;
        break;
      case DeliveryStatus.delivering:
        buttonText = 'ສົ່ງສຳເລັດ';
        nextStatus = DeliveryStatus.delivered;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (delivery.status == DeliveryStatus.pending) {
                await controller.acceptDelivery(delivery);
              } else {
                await controller.updateDeliveryStatus(nextStatus);
              }
              if (nextStatus == DeliveryStatus.delivered) {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
