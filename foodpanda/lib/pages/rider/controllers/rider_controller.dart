import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/services/rider_notification_service.dart';
import '../../../data/repositories/rider_repository.dart';
import '../../../routes/app_routes.dart';

class RiderController extends GetxController {
  final pageController = PageController();
  final RxInt currentIndex = 0.obs;
  final RiderRepository _repository = RiderRepository();

  // Rider Info
  final RxString riderId = ''.obs;
  final RxString riderName = ''.obs;
  final RxString riderPhone = ''.obs;
  final RxString riderEmail = ''.obs;
  final RxString riderAvatar = ''.obs;
  final RxString riderStatus = 'OFFLINE'.obs;
  final RxBool isOnline = false.obs;
  final RxString vehicleType = ''.obs;
  final RxString vehiclePlate = ''.obs;

  // Stats
  final RxInt todayDeliveries = 0.obs;
  final RxInt todayEarnings = 0.obs;
  final RxInt totalDeliveries = 0.obs;
  final RxInt totalEarnings = 0.obs;
  final RxDouble rating = 4.8.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isTogglingStatus = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  // Location
  Position? _currentPosition;

  @override
  void onInit() {
    super.onInit();
    _loadRiderInfo();
    _loadProfile();
    _initNotificationService();
    _getCurrentLocation();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// Load rider info from local storage
  void _loadRiderInfo() {
    final userData = StorageService.userData;
    if (userData != null) {
      riderId.value = userData['id'] ?? '';
      riderName.value = userData['fullName'] ?? '';
      riderPhone.value = userData['phone'] ?? '';
      riderEmail.value = userData['email'] ?? '';
      riderAvatar.value = userData['avatar'] ?? '';
      riderStatus.value = userData['status'] ?? 'OFFLINE';
      isOnline.value = riderStatus.value == 'AVAILABLE';
      vehicleType.value = userData['vehicleType'] ?? '';
      vehiclePlate.value = userData['vehiclePlate'] ?? '';
    }
  }

  /// Load profile from API
  Future<void> _loadProfile() async {
    try {
      final data = await _repository.getProfile();

      // Update rider info
      riderId.value = data['id'] ?? '';
      riderName.value = data['fullName'] ?? '';
      riderPhone.value = data['phone'] ?? '';
      riderEmail.value = data['email'] ?? '';
      riderAvatar.value = data['avatar'] ?? '';
      riderStatus.value = data['status'] ?? 'OFFLINE';
      isOnline.value = riderStatus.value == 'AVAILABLE';
      vehicleType.value = data['vehicleType'] ?? '';
      vehiclePlate.value = data['vehiclePlate'] ?? '';

      // Update stats
      final stats = data['stats'] ?? {};
      todayDeliveries.value = stats['todayDeliveries'] ?? 0;
      todayEarnings.value = stats['todayEarnings'] ?? 0;
      totalDeliveries.value = stats['totalDeliveries'] ?? 0;
      totalEarnings.value = stats['totalEarnings'] ?? 0;

      // Save to local storage
      await StorageService.setUserData(data);
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error loading profile: $e');
    }
  }

  /// Initialize notification service
  Future<void> _initNotificationService() async {
    try {
      await RiderNotificationService().init();
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// Toggle online/offline status
  Future<void> toggleOnlineStatus() async {
    isTogglingStatus.value = true;
    errorMessage.value = '';

    try {
      final newStatus = isOnline.value ? 'OFFLINE' : 'AVAILABLE';

      await _repository.updateStatus(
        status: newStatus,
        currentLat: _currentPosition?.latitude,
        currentLng: _currentPosition?.longitude,
      );

      isOnline.value = !isOnline.value;
      riderStatus.value = newStatus;

      Get.snackbar(
        'ສຳເລັດ',
        isOnline.value ? 'ເປີດຮັບງານແລ້ວ' : 'ປິດຮັບງານແລ້ວ',
        backgroundColor:
            isOnline.value ? Colors.green.shade100 : Colors.grey.shade100,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'ຜິດພາດ',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isTogglingStatus.value = false;
    }
  }

  /// Update rider location (call periodically)
  Future<void> updateLocation() async {
    if (!isOnline.value) return;

    try {
      final position = await Geolocator.getCurrentPosition();
      _currentPosition = position;

      await _repository.updateLocation(
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
      );
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Remove FCM token
      await RiderNotificationService().removeToken();

      // Set offline before logout
      if (isOnline.value) {
        await _repository.updateStatus(status: 'OFFLINE');
      }
    } catch (e) {
      // Ignore errors during logout
    }

    await StorageService.clearAuthData();
    Get.offAllNamed(AppRoutes.login);
  }

  /// Refresh all data
  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await _loadProfile();
    } finally {
      isLoading.value = false;
    }
  }

  /// Format price to display
  String formatPrice(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
