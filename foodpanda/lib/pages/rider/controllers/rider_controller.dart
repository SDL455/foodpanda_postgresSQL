import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/storage_service.dart';
import '../../../routes/app_routes.dart';

class RiderController extends GetxController {
  final pageController = PageController();
  final RxInt currentIndex = 0.obs;

  // Rider Info
  final RxString riderName = ''.obs;
  final RxString riderPhone = ''.obs;
  final RxString riderEmail = ''.obs;
  final RxString riderAvatar = ''.obs;
  final RxString riderStatus = 'OFFLINE'.obs;
  final RxBool isOnline = false.obs;

  // Stats
  final RxInt todayDeliveries = 0.obs;
  final RxDouble todayEarnings = 0.0.obs;
  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble rating = 4.8.obs;

  // Loading states
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRiderInfo();
    _loadStats();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void _loadRiderInfo() {
    final userData = StorageService.userData;
    if (userData != null) {
      riderName.value = userData['fullName'] ?? '';
      riderPhone.value = userData['phone'] ?? '';
      riderEmail.value = userData['email'] ?? '';
      riderAvatar.value = userData['avatar'] ?? '';
      riderStatus.value = userData['status'] ?? 'OFFLINE';
      isOnline.value = riderStatus.value == 'AVAILABLE';
    }
  }

  Future<void> _loadStats() async {
    // TODO: Load from API
    todayDeliveries.value = 12;
    todayEarnings.value = 450000;
    totalEarnings.value = 8500000;
  }

  void changePage(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  Future<void> toggleOnlineStatus() async {
    isLoading.value = true;
    try {
      // TODO: Call API to update status
      await Future.delayed(const Duration(milliseconds: 500));
      isOnline.value = !isOnline.value;
      riderStatus.value = isOnline.value ? 'AVAILABLE' : 'OFFLINE';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAuthData();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await _loadStats();
    } finally {
      isLoading.value = false;
    }
  }
}
