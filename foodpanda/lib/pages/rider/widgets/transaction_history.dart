import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

/// Widget ສະແດງປະຫວັດການທຳທຸລະກຳ
class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const TransactionItem(
            orderNo: 'FP001234',
            amount: 15000,
            time: '14:30',
          ),
          const TransactionItem(
            orderNo: 'FP001233',
            amount: 20000,
            time: '12:45',
          ),
          const TransactionItem(
            orderNo: 'FP001232',
            amount: 18000,
            time: '10:20',
          ),
          const TransactionItem(
            orderNo: 'FP001231',
            amount: 15000,
            time: '09:15',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ປະຫວັດລາຍຮັບ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'ເບິ່ງທັງໝົດ',
              style: TextStyle(fontSize: 13.sp, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget ສະແດງລາຍການທຳທຸລະກຳແຕ່ລະອັນ
class TransactionItem extends StatelessWidget {
  final String orderNo;
  final int amount;
  final String time;
  final bool isLast;

  const TransactionItem({
    super.key,
    required this.orderNo,
    required this.amount,
    required this.time,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: 12.w),
          Expanded(child: _buildInfo()),
          _buildAmount(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.local_shipping,
        color: AppColors.success,
        size: 20.sp,
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ສົ່ງອາຫານ #$orderNo',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          'ວັນນີ້ • $time',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAmount() {
    return Text(
      '+$amount₭',
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.success,
      ),
    );
  }
}
