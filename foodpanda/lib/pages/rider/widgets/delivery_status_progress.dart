import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/delivery_model.dart';

/// Widget ສະແດງຂັ້ນຕອນການສົ່ງອາຫານ
class DeliveryStatusProgress extends StatelessWidget {
  final DeliveryModel delivery;

  const DeliveryStatusProgress({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusStep(
                label: 'ຮັບງານ',
                isActive: _isStatusActive(DeliveryStatus.pickedUp),
                isCompleted: _isStatusCompleted(DeliveryStatus.pickedUp),
              ),
              StatusLine(isCompleted: _isStatusCompleted(DeliveryStatus.pickedUp)),
              StatusStep(
                label: 'ກຳລັງສົ່ງ',
                isActive: _isStatusActive(DeliveryStatus.delivering),
                isCompleted: _isStatusCompleted(DeliveryStatus.delivering),
              ),
              StatusLine(isCompleted: _isStatusCompleted(DeliveryStatus.delivering)),
              StatusStep(
                label: 'ສຳເລັດ',
                isActive: delivery.status == DeliveryStatus.delivered,
                isCompleted: delivery.status == DeliveryStatus.delivered,
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isStatusActive(DeliveryStatus status) {
    return delivery.status.index >= status.index;
  }

  bool _isStatusCompleted(DeliveryStatus status) {
    return delivery.status.index > status.index;
  }
}

/// Widget ສະແດງແຕ່ລະຂັ້ນຕອນ
class StatusStep extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const StatusStep({
    super.key,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success
                : (isActive
                      ? AppColors.white
                      : AppColors.white.withOpacity(0.3)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: AppColors.white, size: 18.sp)
                : Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: isActive
                ? AppColors.white
                : AppColors.white.withOpacity(0.6),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// Widget ເສັ້ນເຊື່ອມຕໍ່ລະຫວ່າງຂັ້ນຕອນ
class StatusLine extends StatelessWidget {
  final bool isCompleted;

  const StatusLine({super.key, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success
              : AppColors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}
