import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/store_orders_controller.dart';

class StoreOrdersView extends GetView<StoreOrdersController> {
  const StoreOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('ຄຳສັ່ງຊື້'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab bar
          Obx(
            () => TabBar(
              controller: TabController(
                length: 4,
                initialIndex: controller.selectedTab.value,
                vsync: Scaffold.of(context),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              onTap: (index) => controller.selectedTab.value = index,
              tabs: const [
                Tab(text: 'ລໍຖ້າ'),
                Tab(text: 'ກະກຽມ'),
                Tab(text: 'ພ້ອມສົ່ງ'),
                Tab(text: 'ສຳເລັດ'),
              ],
            ),
          ),

          // Order list
          Expanded(
            child: Obx(() {
              final orders = controller.currentTabOrders;

              if (controller.isLoading.value && orders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    'ບໍ່ມີຄຳສັ່ງຊື້',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(12.w),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(
                    order: order,
                    onTap: () => _showOrderDetail(context, order),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(BuildContext context, dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          OrderDetailSheet(order: order, controller: controller),
    );
  }
}

class OrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['orderNo'] ?? ''}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    _getStatusLabel(order['status']),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: _getStatusColor(order['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Customer name
            Text(
              order['customerName'] ?? 'ລູກຄ້າ',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
            ),
            SizedBox(height: 4.h),

            // Item count and total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order['itemCount'] ?? 0} ລາຍການ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${order['total'] ?? 0} ₭',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'ລໍຖ້າ';
      case 'CONFIRMED':
        return 'ຢືນຢັນແລ້ວ';
      case 'PREPARING':
        return 'ກະກຽມ';
      case 'READY_FOR_PICKUP':
        return 'ພ້ອມສົ່ງ';
      case 'CANCELLED':
        return 'ຍົກເລີກ';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.warning;
      case 'CONFIRMED':
        return AppColors.info;
      case 'PREPARING':
        return AppColors.primary;
      case 'READY_FOR_PICKUP':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error ?? Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }
}

class OrderDetailSheet extends StatelessWidget {
  final dynamic order;
  final StoreOrdersController controller;

  const OrderDetailSheet({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['orderNo'] ?? ''}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Customer info
              Text(
                'ຂໍ້ມູນລູກຄ້າ',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['customerName'] ?? 'ລູກຄ້າ',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      order['customerPhone'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Items
              Text(
                'ລາຍການ (${order['itemCount'] ?? 0})',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              ...((order['items'] as List?)?.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name']} x${item['quantity']}',
                              style: TextStyle(fontSize: 12.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item['totalPrice'] ?? 0} ₭',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  ) ??
                  []),
              SizedBox(height: 12.h),

              // Total
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ລວມ:', style: TextStyle(fontSize: 12.sp)),
                        Text(
                          '${order['subtotal'] ?? 0} ₭',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ຄ່າສົ່ງ:', style: TextStyle(fontSize: 12.sp)),
                        Text(
                          '${order['deliveryFee'] ?? 0} ₭',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Divider(),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ລວມທັງໝົດ:',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${order['total'] ?? 0} ₭',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Action buttons
              Obx(
                () => controller.isUpdatingStatus.value
                    ? const Center(child: CircularProgressIndicator())
                    : _buildActionButtons(context, order),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic order) {
    final status = order['status'] as String;

    switch (status) {
      case 'PENDING':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              controller.confirmOrder(order['id']);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              'ຢືນຢັນ Order',
              style: TextStyle(fontSize: 14.sp, color: AppColors.white),
            ),
          ),
        );

      case 'CONFIRMED':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              controller.startPreparing(order['id']);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              'ເລີ່ມກະກຽມ',
              style: TextStyle(fontSize: 14.sp, color: AppColors.white),
            ),
          ),
        );

      case 'PREPARING':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              controller.markReady(order['id']);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              'ພ້ອມສົ່ງ',
              style: TextStyle(fontSize: 14.sp, color: AppColors.white),
            ),
          ),
        );

      default:
        return SizedBox.shrink();
    }
  }
}
