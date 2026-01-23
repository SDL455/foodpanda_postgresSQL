import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: _getTextColor(),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning.withOpacity(0.1);
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
      case OrderStatus.ready:
        return AppColors.info.withOpacity(0.1);
      case OrderStatus.onTheWay:
        return AppColors.primary.withOpacity(0.1);
      case OrderStatus.delivered:
        return AppColors.success.withOpacity(0.1);
      case OrderStatus.cancelled:
        return AppColors.error.withOpacity(0.1);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
      case OrderStatus.ready:
        return AppColors.info;
      case OrderStatus.onTheWay:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText() {
    switch (status) {
      case OrderStatus.pending:
        return 'ລໍຖ້າ';
      case OrderStatus.confirmed:
        return 'ຢືນຢັນແລ້ວ';
      case OrderStatus.preparing:
        return 'ກຳລັງກະກຽມ';
      case OrderStatus.ready:
        return 'ພ້ອມສົ່ງ';
      case OrderStatus.onTheWay:
        return 'ກຳລັງສົ່ງ';
      case OrderStatus.delivered:
        return 'ສົ່ງແລ້ວ';
      case OrderStatus.cancelled:
        return 'ຍົກເລີກ';
    }
  }
}
