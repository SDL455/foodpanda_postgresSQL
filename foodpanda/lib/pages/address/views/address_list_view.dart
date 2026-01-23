import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/address_controller.dart';
import '../widgets/address_add_edit_dialog.dart';
import '../widgets/address_card_widget.dart';
import '../widgets/address_empty_state.dart';
import '../widgets/address_shimmer_loading.dart';

/// View ສຳລັບສະແດງລາຍການທີ່ຢູ່ທັງໝົດ
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
        child: Obx(() => _buildBody()),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// ສ້າງ body ຕາມສະຖານະ
  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const AddressShimmerLoading();
    }

    if (controller.addresses.isEmpty) {
      return const AddressEmptyState();
    }

    return _buildAddressList();
  }

  /// ລາຍການທີ່ຢູ່
  Widget _buildAddressList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.addresses.length,
      itemBuilder: (context, index) {
        final address = controller.addresses[index];
        return AddressCardWidget(
          address: address,
          onEdit: () {
            controller.prepareForEdit(address);
            AddressAddEditDialog.show();
          },
          onSetDefault: () => controller.setAsDefault(address.id),
          onDelete: () => controller.deleteAddress(address.id),
        );
      },
    );
  }

  /// ປຸ່ມເພີ່ມທີ່ຢູ່
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        controller.prepareForAdd();
        AddressAddEditDialog.show();
      },
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'ເພີ່ມທີ່ຢູ່',
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
      ),
    );
  }
}
