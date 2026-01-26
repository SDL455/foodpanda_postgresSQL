import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/address_model.dart';

/// Widget ສະແດງ card ຂອງທີ່ຢູ່ແຕ່ລະອັນ
class AddressCardWidget extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onEdit;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;

  const AddressCardWidget({
    super.key,
    required this.address,
    this.onEdit,
    this.onSetDefault,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: address.isDefault
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildIconContainer(),
                SizedBox(width: 12.w),
                Expanded(child: _buildAddressInfo()),
                _buildPopupMenu(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Container ສຳລັບ icon ປະເພດທີ່ຢູ່
  Widget _buildIconContainer() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        _getIconForLabel(address.label),
        color: AppColors.primary,
        size: 24.sp,
      ),
    );
  }

  /// ຂໍ້ມູນທີ່ຢູ່
  Widget _buildAddressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              address.label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (address.isDefault) ...[
              SizedBox(width: 8.w),
              _buildDefaultBadge(),
            ],
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          address.address,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (address.detail != null && address.detail!.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            address.detail!,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.grey500,
            ),
          ),
        ],
      ],
    );
  }

  /// Badge ທີ່ຢູ່ຫຼັກ
  Widget _buildDefaultBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        'ທີ່ຢູ່ຫຼັກ',
        style: TextStyle(
          fontSize: 10.sp,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Popup menu ສຳລັບແກ້ໄຂ, ຕັ້ງເປັນຫຼັກ, ລຶບ
  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'default':
            onSetDefault?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit, size: 20),
              SizedBox(width: 8.w),
              const Text('ແກ້ໄຂ'),
            ],
          ),
        ),
        if (!address.isDefault)
          PopupMenuItem(
            value: 'default',
            child: Row(
              children: [
                const Icon(Icons.star, size: 20),
                SizedBox(width: 8.w),
                const Text('ຕັ້ງເປັນທີ່ຢູ່ຫຼັກ'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: AppColors.error),
              SizedBox(width: 8.w),
              Text('ລຶບ', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  /// ເລືອກ icon ຕາມປະເພດທີ່ຢູ່
  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'ເຮືອນ':
        return Icons.home;
      case 'ບ່ອນເຮັດວຽກ':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}
