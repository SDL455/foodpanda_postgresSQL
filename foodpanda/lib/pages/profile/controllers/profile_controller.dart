import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
  final RxBool isUploadingAvatar = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  final ImagePicker _imagePicker = ImagePicker();

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

  // Pick and upload avatar
  Future<void> pickAndUploadAvatar({ImageSource source = ImageSource.gallery}) async {
    // Check if user is logged in
    final token = StorageService.token;
    if (token == null || token.isEmpty) {
      LoggerService.warning('No token found, redirecting to login');
      Helpers.showSnackbar(
        title: 'ກະລຸນາເຂົ້າສູ່ລະບົບໃໝ່',
        message: 'Session ໝົດອາຍຸ ກະລຸນາເຂົ້າສູ່ລະບົບໃໝ່',
        isError: true,
      );
      await StorageService.clearAuthData();
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      isUploadingAvatar.value = true;
      uploadProgress.value = 0.0;

      LoggerService.info('Uploading avatar...');
      final File imageFile = File(pickedFile.path);
      final String avatarUrl = await _repository.uploadAvatar(imageFile);
      LoggerService.info('Avatar uploaded: $avatarUrl');

      // Update profile with new avatar URL
      LoggerService.info('Updating profile with new avatar...');
      final updatedUser = await _repository.updateProfile(
        avatar: avatarUrl,
      );

      user.value = updatedUser;
      await StorageService.setUserData(user.value!.toJson());
      _initFormControllers();

      Helpers.showSnackbar(
        title: 'ສຳເລັດ',
        message: 'ອັບເດດຮູບໂປຣໄຟລ໌ສຳເລັດ',
      );
    } catch (e) {
      LoggerService.error('Failed to upload avatar', e);
      
      // Check if it's an authentication error (401)
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('401') || errorMessage.contains('unauthorized')) {
        Helpers.showSnackbar(
          title: 'Session ໝົດອາຍຸ',
          message: 'ກະລຸນາເຂົ້າສູ່ລະບົບໃໝ່',
          isError: true,
        );
        await StorageService.clearAuthData();
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດອັບໂຫຼດຮູບໄດ້',
        isError: true,
      );
    } finally {
      isUploadingAvatar.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // Show image source picker dialog
  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ເລືອກຮູບພາບ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('ເລືອກຈາກຄັງຮູບ'),
              onTap: () {
                Get.back();
                pickAndUploadAvatar(source: ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('ຖ່າຍຮູບໃໝ່'),
              onTap: () {
                Get.back();
                pickAndUploadAvatar(source: ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
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
