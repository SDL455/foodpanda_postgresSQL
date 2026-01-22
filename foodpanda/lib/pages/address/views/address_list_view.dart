import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/address_model.dart';
import '../../../widgets/shimmer_loading.dart';
import '../controllers/address_controller.dart';

class AddressListView extends GetView<AddressController> {
  const AddressListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(AppStrings.myAddresses)),
      body: RefreshIndicator(
        onRefresh: controller.refreshAddresses,
        color: AppColors.primary,
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading();
          }

          if (controller.addresses.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              return _buildAddressCard(controller.addresses[index]);
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.prepareForAdd();
          _showAddEditDialog();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'ເພີ່ມທີ່ຢູ່',
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
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
                Container(
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
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
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
                            Container(
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
                            ),
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
                      if (address.detail != null &&
                          address.detail!.isNotEmpty) ...[
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
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        controller.prepareForEdit(address);
                        _showAddEditDialog();
                        break;
                      case 'default':
                        controller.setAsDefault(address.id);
                        break;
                      case 'delete':
                        controller.deleteAddress(address.id);
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  void _showAddEditDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      controller.selectedAddress.value != null
                          ? 'ແກ້ໄຂທີ່ຢູ່'
                          : 'ເພີ່ມທີ່ຢູ່ໃໝ່',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Label selection
              Text(
                'ປະເພດທີ່ຢູ່',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => Wrap(
                  spacing: 8.w,
                  children: controller.predefinedLabels.map((label) {
                    final isSelected = controller.selectedLabel.value == label;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectedLabel.value = label;
                          if (label != 'ອື່ນໆ') {
                            controller.labelController.text = label;
                          }
                        }
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Custom label input (only show if "ອື່ນໆ" is selected)
              Obx(() {
                if (controller.selectedLabel.value == 'ອື່ນໆ') {
                  return Column(
                    children: [
                      SizedBox(height: 12.h),
                      TextField(
                        controller: controller.labelController,
                        decoration: InputDecoration(
                          labelText: 'ຊື່ທີ່ຢູ່',
                          prefixIcon: const Icon(Icons.label_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              SizedBox(height: 16.h),
              TextField(
                controller: controller.addressController,
                decoration: InputDecoration(
                  labelText: 'ທີ່ຢູ່ *',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller.detailController,
                decoration: InputDecoration(
                  labelText: 'ລາຍລະອຽດເພີ່ມເຕີມ (ຕຶກ, ຊັ້ນ, ຫ້ອງ)',
                  prefixIcon: const Icon(Icons.apartment_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Default checkbox
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ຕັ້ງເປັນທີ່ຢູ່ຫຼັກ'),
                  value: controller.isDefault.value,
                  onChanged: (value) {
                    controller.isDefault.value = value ?? false;
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                ),
              ),

              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: controller.isSaving.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            'ບັນທຶກ',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 100.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 24.h),
          Text(
            'ຍັງບໍ່ມີທີ່ຢູ່',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ເພີ່ມທີ່ຢູ່ເພື່ອຄວາມສະດວກໃນການສັ່ງອາຫານ',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ShimmerLoading(
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
              height: 100.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
