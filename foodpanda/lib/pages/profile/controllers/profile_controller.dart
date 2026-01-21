import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  // Form controllers for edit profile
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final avatarController = TextEditingController();

  final ApiClient _apiClient = ApiClient();

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
      final response = await _apiClient.get(ApiConstants.profile);

      if (response.data['success'] == true && response.data['data'] != null) {
        final userData = response.data['data'];
        user.value = UserModel.fromJson(userData);
        await StorageService.setUserData(user.value!.toJson());
        _initFormControllers();
      }
    } catch (e) {
      LoggerService.error('Failed to refresh user data', e);
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

      final response = await _apiClient.patch(
        ApiConstants.updateProfile,
        data: {
          'fullName': fullNameController.text.trim(),
          'phone': phoneController.text.trim().isNotEmpty
              ? phoneController.text.trim()
              : null,
          'avatar': avatarController.text.trim().isNotEmpty
              ? avatarController.text.trim()
              : null,
        },
      );

      if (response.data['success'] == true) {
        // Update local user data
        user.value = user.value!.copyWith(
          fullName: fullNameController.text.trim(),
          phone: phoneController.text.trim().isNotEmpty
              ? phoneController.text.trim()
              : null,
          avatar: avatarController.text.trim().isNotEmpty
              ? avatarController.text.trim()
              : null,
        );

        await StorageService.setUserData(user.value!.toJson());

        Helpers.showSnackbar(title: 'ສຳເລັດ', message: 'ອັບເດດໂປຣໄຟລ໌ສຳເລັດ');

        Get.back();
      } else {
        throw Exception(response.data['message'] ?? 'ເກີດຂໍ້ຜິດພາດ');
      }
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

  void logout() {
    Get.find<AuthController>().logout();
  }
}
