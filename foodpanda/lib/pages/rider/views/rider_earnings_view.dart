import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_controller.dart';
import '../widgets/widgets.dart';

class RiderEarningsView extends GetView<RiderController> {
  const RiderEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = 0.obs;

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
              EarningsSummaryCard(controller: controller),

              SizedBox(height: 16.h),

              // Period Selector
              PeriodSelector(selectedPeriod: selectedPeriod),

              SizedBox(height: 16.h),

              // Earnings Chart
              const EarningsChart(),

              SizedBox(height: 16.h),

              // Transaction History
              const TransactionHistory(),
            ],
          ),
        ),
      ),
    );
  }
}
