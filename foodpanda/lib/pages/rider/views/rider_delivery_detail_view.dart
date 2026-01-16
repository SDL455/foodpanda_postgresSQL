import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_delivery_controller.dart';
import '../widgets/widgets.dart';

class RiderDeliveryDetailView extends StatelessWidget {
  final DeliveryItem delivery;

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
              address: delivery.storeAddress,
              phone: null,
              onNavigate: () => _openMap(delivery.storeLat, delivery.storeLng),
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
              onCall: () => _makePhoneCall(delivery.customerPhone),
            ),

            SizedBox(height: 12.h),

            // Order Details Card
            OrderDetailsCard(
              totalAmount: delivery.totalAmount.toDouble(),
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
