import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  // Form controllers for edit profile
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final avatarController = TextEditingController();

  final ProfileRepository _repository = ProfileRepository();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    avatarController.dispose();
    super.onClose();
  }

  void loadUserData() {
    final userData = StorageService.userData;
    if (userData != null) {
      user.value = UserModel.fromJson(userData);
      _initFormControllers();
    }
  }

  void _initFormControllers() {
    if (user.value != null) {
      fullNameController.text = user.value!.fullName ?? '';
      phoneController.text = user.value!.phone ?? '';
      avatarController.text = user.value!.avatar ?? '';
    }
  }

  // Refresh user data from server
  Future<void> refreshUserData() async {
    try {
      isLoading.value = true;
      final userData = await _repository.getProfile();
      user.value = userData;
      await StorageService.setUserData(user.value!.toJson());
      _initFormControllers();
    } catch (e) {
      LoggerService.error('Failed to refresh user data', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile
  Future<void> updateProfile() async {
    if (fullNameController.text.trim().isEmpty) {
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ກະລຸນາໃສ່ຊື່',
        isError: true,
      );
      return;
    }

    try {
      isUpdating.value = true;

      final updatedUser = await _repository.updateProfile(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        avatar: avatarController.text.trim().isNotEmpty
            ? avatarController.text.trim()
            : null,
      );

      user.value = updatedUser;
      await StorageService.setUserData(user.value!.toJson());

      Helpers.showSnackbar(title: 'ສຳເລັດ', message: 'ອັບເດດໂປຣໄຟລ໌ສຳເລັດ');
      Get.back();
    } catch (e) {
      LoggerService.error('Failed to update profile', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: e.toString(),
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // Get formatted date
  String getFormattedJoinDate() {
    if (user.value?.createdAt != null) {
      final date = user.value!.createdAt!;
      return '${date.day}/${date.month}/${date.year}';
    }
    return '-';
  }

  // Get auth provider text
  String getAuthProviderText() {
    switch (user.value?.authProvider) {
      case 'GOOGLE':
        return 'Google';
      case 'FACEBOOK':
        return 'Facebook';
      case 'APPLE':
        return 'Apple';
      case 'EMAIL':
        return 'Email';
      case 'PHONE':
        return 'ເບີໂທ';
      default:
        return user.value?.authProvider ?? '-';
    }
  }

  // Navigation methods
  void goToAddresses() {
    Get.toNamed(AppRoutes.addresses);
  }

  void goToOrderHistory() {
    Get.toNamed(AppRoutes.orders);
  }

  void goToFavorites() {
    Get.toNamed(AppRoutes.favorites);
  }

  void goToNotifications() {
    Get.toNamed(AppRoutes.notifications);
  }

  void goToHelp() {
    // Show help dialog or navigate to help page
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('ຊ່ວຍເຫຼືອ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(Icons.phone, 'ໂທຫາພວກເຮົາ', '020 12345678'),
            const SizedBox(height: 12),
            _buildHelpItem(Icons.email, 'ອີເມວ', 'support@foodpanda.la'),
            const SizedBox(height: 12),
            _buildHelpItem(Icons.language, 'ເວັບໄຊ', 'www.foodpanda.la'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ປິດ'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  void logout() {
    Get.find<AuthController>().logout();
  }
}
