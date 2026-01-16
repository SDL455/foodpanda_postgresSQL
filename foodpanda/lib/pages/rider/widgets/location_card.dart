import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

/// Widget ສະແດງຂໍ້ມູນສະຖານທີ່ (ຮ້ານ / ລູກຄ້າ)
class LocationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String name;
  final String address;
  final String? phone;
  final VoidCallback onNavigate;
  final VoidCallback? onCall;

  const LocationCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.name,
    required this.address,
    this.phone,
    required this.onNavigate,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(),
          SizedBox(height: 12.h),
          _buildAddress(),
          if (phone != null) ...[
            SizedBox(height: 8.h),
            _buildPhone(),
          ],
          SizedBox(height: 16.h),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
    );
  }

  Widget _buildAddress() {
    return Row(
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
    );
  }

  Widget _buildPhone() {
    return Row(
      children: [
        Icon(
          Icons.phone_outlined,
          size: 18.sp,
          color: AppColors.grey500,
        ),
        SizedBox(width: 8.w),
        Text(
          phone!,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
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
    );
  }
}
