import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';

class RiderEarningsView extends GetView<RiderController> {
  const RiderEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          'ລາຍຮັບ',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Earnings Summary Card
              _buildEarningsSummary(),

              SizedBox(height: 16.h),

              // Period Selector
              _buildPeriodSelector(),

              SizedBox(height: 16.h),

              // Earnings Chart Placeholder
              _buildEarningsChart(),

              SizedBox(height: 16.h),

              // Transaction History
              _buildTransactionHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsSummary() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'ລາຍຮັບທັງໝົດ',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              '${controller.totalEarnings.value.toStringAsFixed(0)}₭',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.today,
                  label: 'ວັນນີ້',
                  value: controller.todayEarnings,
                ),
              ),
              Container(
                width: 1,
                height: 50.h,
                color: AppColors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.local_shipping,
                  label: 'ສົ່ງແລ້ວ',
                  value: controller.todayDeliveries,
                  isCurrency: false,
                  suffix: ' ເທື່ອ',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required Rx value,
    bool isCurrency = true,
    String suffix = '',
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white.withOpacity(0.8), size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4.h),
        Obx(() {
          String displayValue;
          if (isCurrency) {
            displayValue = '${(value.value as double).toStringAsFixed(0)}₭';
          } else {
            displayValue = '${value.value}$suffix';
          }
          return Text(
            displayValue,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['ວັນນີ້', 'ອາທິດ', 'ເດືອນ', 'ທັງໝົດ'];
    final selectedPeriod = 0.obs;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Obx(
        () => Row(
          children: periods.asMap().entries.map((entry) {
            final isSelected = selectedPeriod.value == entry.key;
            return Expanded(
              child: GestureDetector(
                onTap: () => selectedPeriod.value = entry.key,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEarningsChart() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
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
          Text(
            'ລາຍຮັບ 7 ມື້ຜ່ານມາ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          // Simple bar chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('ຈ', 0.6),
              _buildChartBar('ອ', 0.8),
              _buildChartBar('ພ', 0.4),
              _buildChartBar('ພຫ', 0.9),
              _buildChartBar('ສ', 1.0),
              _buildChartBar('ສ', 0.7),
              _buildChartBar('ອາ', 0.5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double percentage) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            Container(
              height: 100.h * percentage,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              day,
              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
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
          Padding(
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
          ),
          // Transaction items
          _buildTransactionItem(
            orderNo: 'FP001234',
            amount: 15000,
            time: '14:30',
          ),
          _buildTransactionItem(
            orderNo: 'FP001233',
            amount: 20000,
            time: '12:45',
          ),
          _buildTransactionItem(
            orderNo: 'FP001232',
            amount: 18000,
            time: '10:20',
          ),
          _buildTransactionItem(
            orderNo: 'FP001231',
            amount: 15000,
            time: '09:15',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String orderNo,
    required int amount,
    required String time,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Container(
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
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
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
            ),
          ),
          Text(
            '+$amount₭',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
