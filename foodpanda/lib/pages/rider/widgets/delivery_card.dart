import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/delivery_model.dart';
import '../controllers/rider_delivery_controller.dart';
import '../views/rider_delivery_detail_view.dart';

/// Widget ສະແດງ Card ຂອງງານສົ່ງແຕ່ລະອັນ
class DeliveryCard extends StatelessWidget {
  final DeliveryModel delivery;
  final RiderDeliveryController controller;

  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              Get.to(() => RiderDeliveryDetailView(delivery: delivery)),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 16.h),
                _buildStoreInfo(),
                _buildDottedLine(),
                _buildCustomerInfo(),
                SizedBox(height: 16.h),
                if (delivery.canAccept) _buildAcceptButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildOrderNumber(),
            SizedBox(width: 8.w),
            if (delivery.distance != null) _buildDistance(),
          ],
        ),
        _buildDeliveryFee(),
      ],
    );
  }

  Widget _buildOrderNumber() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        '#${delivery.orderNo}',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDistance() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 14.sp, color: AppColors.grey500),
        SizedBox(width: 2.w),
        Text(
          '${delivery.distance?.toStringAsFixed(1)} km',
          style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
        ),
      ],
    );
  }

  Widget _buildDeliveryFee() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        delivery.formattedDeliveryFee,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.success,
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Row(
      children: [
        _buildInfoIcon(Icons.store, AppColors.warning),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ຮ້ານ',
                style:
                    TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
              ),
              Text(
                delivery.storeName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (delivery.storeAddress != null)
                Text(
                  delivery.storeAddress!,
                  style:
                      TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDottedLine() {
    return Padding(
      padding: EdgeInsets.only(left: 19.w),
      child: Container(
        width: 2,
        height: 20.h,
        color: AppColors.grey300,
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Row(
      children: [
        _buildInfoIcon(Icons.person, AppColors.success),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ລູກຄ້າ',
                style:
                    TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
              ),
              Text(
                delivery.customerName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                delivery.customerAddress,
                style:
                    TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 16.sp),
    );
  }

  Widget _buildAcceptButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                controller.isAccepting.value
                    ? null
                    : () => controller.acceptDelivery(delivery),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
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
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
          ),
        ));
  }
}
