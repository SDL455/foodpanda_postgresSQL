import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rider_delivery_controller.dart';

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
            _buildStatusProgress(controller),

            SizedBox(height: 16.h),

            // Store Info Card
            _buildLocationCard(
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
            _buildLocationCard(
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
            _buildOrderDetailsCard(),

            SizedBox(height: 100.h),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(controller),
    );
  }

  Widget _buildStatusProgress(RiderDeliveryController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusStep(
                label: 'ຮັບງານ',
                isActive:
                    delivery.status.index >= DeliveryStatus.accepted.index,
                isCompleted:
                    delivery.status.index > DeliveryStatus.accepted.index,
              ),
              _buildStatusLine(
                delivery.status.index > DeliveryStatus.accepted.index,
              ),
              _buildStatusStep(
                label: 'ຮັບອາຫານ',
                isActive:
                    delivery.status.index >= DeliveryStatus.pickedUp.index,
                isCompleted:
                    delivery.status.index > DeliveryStatus.pickedUp.index,
              ),
              _buildStatusLine(
                delivery.status.index > DeliveryStatus.pickedUp.index,
              ),
              _buildStatusStep(
                label: 'ກຳລັງສົ່ງ',
                isActive:
                    delivery.status.index >= DeliveryStatus.delivering.index,
                isCompleted:
                    delivery.status.index > DeliveryStatus.delivering.index,
              ),
              _buildStatusLine(
                delivery.status.index > DeliveryStatus.delivering.index,
              ),
              _buildStatusStep(
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

  Widget _buildStatusStep({
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
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

  Widget _buildStatusLine(bool isCompleted) {
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

  Widget _buildLocationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String name,
    required String address,
    String? phone,
    required VoidCallback onNavigate,
    VoidCallback? onCall,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18.sp,
                color: AppColors.grey500,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (phone != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 18.sp,
                  color: AppColors.grey500,
                ),
                SizedBox(width: 8.w),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNavigate,
                  icon: Icon(Icons.navigation, size: 18.sp),
                  label: Text('ນຳທາງ', style: TextStyle(fontSize: 13.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              if (onCall != null) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCall,
                    icon: Icon(Icons.call, size: 18.sp),
                    label: Text('ໂທຫາ', style: TextStyle(fontSize: 13.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ລາຍລະອຽດ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailRow('ມູນຄ່າອາຫານ', '${delivery.totalAmount}₭'),
          _buildDetailRow('ຄ່າຈັດສົ່ງ', '${delivery.deliveryFee}₭'),
          Divider(height: 24.h),
          _buildDetailRow(
            'ລາຍຮັບທ່ານ',
            '${delivery.deliveryFee}₭',
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: isHighlight
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: isHighlight ? AppColors.success : AppColors.textPrimary,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(RiderDeliveryController controller) {
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
