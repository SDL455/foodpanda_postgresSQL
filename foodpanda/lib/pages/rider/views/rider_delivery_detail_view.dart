import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodpanda/pages/rider/widgets/delivery_bottom_actions.dart';
import 'package:foodpanda/pages/rider/widgets/delivery_status_progress.dart';
import 'package:foodpanda/pages/rider/widgets/location_card.dart';
import 'package:foodpanda/pages/rider/widgets/order_details_card.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/delivery_model.dart';
import '../controllers/rider_delivery_controller.dart';

class RiderDeliveryDetailView extends StatelessWidget {
  final DeliveryModel delivery;

  const RiderDeliveryDetailView({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RiderDeliveryController>();

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          'ງານສົ່ງ #${delivery.orderNo}',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Progress
            DeliveryStatusProgress(delivery: delivery),

            SizedBox(height: 16.h),

            // Store Info Card
            LocationCard(
              icon: Icons.store,
              iconColor: AppColors.warning,
              title: 'ຮ້ານ',
              name: delivery.storeName,
              address: delivery.storeAddress ?? '',
              phone: delivery.storePhone,
              onNavigate: delivery.storeLat != null && delivery.storeLng != null
                  ? () => _openMap(delivery.storeLat!, delivery.storeLng!)
                  : () {},
              onCall: delivery.storePhone != null
                  ? () => _makePhoneCall(delivery.storePhone!)
                  : () {},
            ),

            SizedBox(height: 12.h),

            // Customer Info Card
            LocationCard(
              icon: Icons.person,
              iconColor: AppColors.success,
              title: 'ລູກຄ້າ',
              name: delivery.customerName,
              address: delivery.customerAddress,
              phone: delivery.customerPhone,
              onNavigate: () =>
                  _openMap(delivery.customerLat, delivery.customerLng),
              onCall: delivery.customerPhone.isNotEmpty
                  ? () => _makePhoneCall(delivery.customerPhone)
                  : null,
            ),

            // Delivery Note
            if (delivery.deliveryNote != null &&
                delivery.deliveryNote!.isNotEmpty)
              _buildDeliveryNote(),

            SizedBox(height: 12.h),

            // Order Items
            _buildOrderItems(),

            SizedBox(height: 12.h),

            // Order Details Card
            OrderDetailsCard(
              totalAmount: delivery.subtotal.toDouble(),
              deliveryFee: delivery.deliveryFee.toDouble(),
            ),

            SizedBox(height: 100.h),
          ],
        ),
      ),
      bottomSheet: DeliveryBottomActions(
        delivery: delivery,
        controller: controller,
      ),
    );
  }

  Widget _buildDeliveryNote() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.note, color: AppColors.warning, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ໝາຍເຫດຈາກລູກຄ້າ:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  delivery.deliveryNote!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    if (delivery.items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'ລາຍການສິນຄ້າ (${delivery.itemCount} ລາຍການ)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...delivery.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
