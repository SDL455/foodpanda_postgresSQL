import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/address_controller.dart';

/// Bottom sheet dialog ສຳລັບເພີ່ມ/ແກ້ໄຂທີ່ຢູ່
class AddressAddEditDialog extends GetView<AddressController> {
  const AddressAddEditDialog({super.key});

  /// ສະແດງ dialog
  static void show() {
    Get.bottomSheet(
      const AddressAddEditDialog(),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            _buildHeader(),
            SizedBox(height: 16.h),
            _buildLabelSelection(),
            _buildCustomLabelInput(),
            SizedBox(height: 16.h),
            _buildAddressField(),
            SizedBox(height: 16.h),
            _buildDetailField(),
            SizedBox(height: 16.h),
            _buildDefaultCheckbox(),
            SizedBox(height: 24.h),
            _buildSaveButton(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  /// Header ຂອງ dialog
  Widget _buildHeader() {
    return Row(
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
    );
  }

  /// ເລືອກປະເພດທີ່ຢູ່
  Widget _buildLabelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Input ສຳລັບຊື່ທີ່ຢູ່ custom (ເມື່ອເລືອກ "ອື່ນໆ")
  Widget _buildCustomLabelInput() {
    return Obx(() {
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
    });
  }

  /// Input ສຳລັບທີ່ຢູ່
  Widget _buildAddressField() {
    return TextField(
      controller: controller.addressController,
      decoration: InputDecoration(
        labelText: 'ທີ່ຢູ່ *',
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      maxLines: 2,
    );
  }

  /// Input ສຳລັບລາຍລະອຽດເພີ່ມເຕີມ
  Widget _buildDetailField() {
    return TextField(
      controller: controller.detailController,
      decoration: InputDecoration(
        labelText: 'ລາຍລະອຽດເພີ່ມເຕີມ (ຕຶກ, ຊັ້ນ, ຫ້ອງ)',
        prefixIcon: const Icon(Icons.apartment_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  /// Checkbox ສຳລັບຕັ້ງເປັນທີ່ຢູ່ຫຼັກ
  Widget _buildDefaultCheckbox() {
    return Obx(
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
    );
  }

  /// ປຸ່ມບັນທຶກ
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isSaving.value ? null : controller.saveAddress,
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
    );
  }
}
