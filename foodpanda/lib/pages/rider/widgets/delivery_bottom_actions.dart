import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/delivery_model.dart';
import '../controllers/rider_delivery_controller.dart';

/// Widget ປຸ່ມກົດຢູ່ລຸ່ມສຳລັບອັບເດດສະຖານະການສົ່ງ
class DeliveryBottomActions extends StatelessWidget {
  final DeliveryModel delivery;
  final RiderDeliveryController controller;

  const DeliveryBottomActions({
    super.key,
    required this.delivery,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show button if delivery is completed or can be accepted
    if (delivery.isCompleted) {
      return const SizedBox.shrink();
    }

    // For available deliveries, show accept button
    if (delivery.canAccept) {
      return _buildAcceptButton();
    }

    // For active deliveries, show next status button
    if (delivery.isActive && delivery.nextStatus != null) {
      return _buildStatusButton();
    }

    return const SizedBox.shrink();
  }

  Widget _buildAcceptButton() {
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
        child: Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isAccepting.value
                    ? null
                    : () async {
                        final success = await controller.acceptDelivery(delivery);
                        if (success) {
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
                child: controller.isAccepting.value
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'ຮັບງານນີ້',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )),
      ),
    );
  }

  Widget _buildStatusButton() {
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
        child: Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isUpdatingStatus.value
                    ? null
                    : () async {
                        // Set current delivery first
                        controller.setCurrentDelivery(delivery);
                        
                        final success = await controller.proceedToNextStatus();
                        if (success &&
                            delivery.nextStatus == DeliveryStatus.delivered) {
                          Get.back();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(),
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: controller.isUpdatingStatus.value
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        delivery.actionText,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )),
      ),
    );
  }

  Color _getButtonColor() {
    switch (delivery.nextStatus) {
      case DeliveryStatus.delivered:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}
