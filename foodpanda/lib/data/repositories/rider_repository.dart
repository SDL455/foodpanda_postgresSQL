import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

/// Repository ສຳລັບຈັດການ API calls ຂອງ Rider
class RiderRepository {
  final ApiClient _apiClient = ApiClient();

  // ============================================
  // Delivery APIs
  // ============================================

  /// ດຶງລາຍການ deliveries
  /// [type]: available, active, completed
  Future<Map<String, dynamic>> getDeliveries({
    String type = 'available',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.riderDeliveries}?type=$type&page=$page&limit=$limit',
    );

    if (response.data['success'] == true) {
      return {
        'deliveries': response.data['data'] ?? [],
        'meta': response.data['meta'] ?? {},
      };
    }
    throw Exception(response.data['message'] ?? 'Failed to get deliveries');
  }

  /// ຮັບ delivery
  Future<Map<String, dynamic>> acceptDelivery(String orderId) async {
    final response = await _apiClient.post(
      '${ApiConstants.riderDeliveries}/$orderId/accept',
    );

    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception(response.data['message'] ?? 'Failed to accept delivery');
  }

  /// ອັບເດດສະຖານະ delivery
  Future<Map<String, dynamic>> updateDeliveryStatus({
    required String orderId,
    required String status,
    double? currentLat,
    double? currentLng,
    String? note,
  }) async {
    final response = await _apiClient.patch(
      '${ApiConstants.riderDeliveries}/$orderId/status',
      data: {
        'status': status,
        if (currentLat != null) 'currentLat': currentLat,
        if (currentLng != null) 'currentLng': currentLng,
        if (note != null) 'note': note,
      },
    );

    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception(
      response.data['message'] ?? 'Failed to update delivery status',
    );
  }

  // ============================================
  // Profile APIs
  // ============================================

  /// ດຶງ profile ຂອງ rider
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get(ApiConstants.riderProfileMobile);

    if (response.data['success'] == true && response.data['data'] != null) {
      return response.data['data'];
    }
    throw Exception(response.data['message'] ?? 'Failed to get profile');
  }

  /// ອັບເດດ profile
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
    String? avatar,
    String? vehicleType,
    String? vehiclePlate,
  }) async {
    final response = await _apiClient.patch(
      ApiConstants.riderProfileMobile,
      data: {
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
        if (vehicleType != null) 'vehicleType': vehicleType,
        if (vehiclePlate != null) 'vehiclePlate': vehiclePlate,
      },
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      return response.data['data'];
    }
    throw Exception(response.data['message'] ?? 'Failed to update profile');
  }

  /// ອັບເດດສະຖານະ online/offline
  Future<Map<String, dynamic>> updateStatus({
    required String status,
    double? currentLat,
    double? currentLng,
  }) async {
    final response = await _apiClient.patch(
      ApiConstants.riderStatus,
      data: {
        'status': status,
        if (currentLat != null) 'currentLat': currentLat,
        if (currentLng != null) 'currentLng': currentLng,
      },
    );

    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception(response.data['message'] ?? 'Failed to update status');
  }

  /// ອັບເດດ location
  Future<void> updateLocation({
    required double lat,
    required double lng,
    double? accuracy,
    double? speed,
  }) async {
    final response = await _apiClient.patch(
      ApiConstants.riderLocation,
      data: {
        'lat': lat,
        'lng': lng,
        if (accuracy != null) 'accuracy': accuracy,
        if (speed != null) 'speed': speed,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to update location');
    }
  }

  // ============================================
  // Earnings APIs
  // ============================================

  /// ດຶງລາຍງານລາຍຮັບ
  Future<Map<String, dynamic>> getEarnings({
    String period = 'today',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.riderEarnings}?period=$period&page=$page&limit=$limit',
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      return response.data['data'];
    }
    throw Exception(response.data['message'] ?? 'Failed to get earnings');
  }

  // ============================================
  // Notification APIs
  // ============================================

  /// ດຶງ notifications
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.riderNotifications}?page=$page&limit=$limit',
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    }
    return [];
  }

  /// ດຶງຈຳນວນ notifications ທີ່ຍັງບໍ່ອ່ານ
  Future<int> getUnreadNotificationCount() async {
    final response = await _apiClient.get(
      ApiConstants.riderNotificationUnreadCount,
    );

    if (response.data['success'] == true) {
      return response.data['data']?['count'] ?? 0;
    }
    return 0;
  }

  /// ໝາຍວ່າອ່ານ notification ແລ້ວ
  Future<void> markNotificationAsRead(String id) async {
    await _apiClient.patch('${ApiConstants.riderNotifications}/$id/read');
  }

  /// ໝາຍວ່າອ່ານທຸກ notifications ແລ້ວ
  Future<void> markAllNotificationsAsRead() async {
    await _apiClient.patch(ApiConstants.riderNotificationReadAll);
  }

  // ============================================
  // Device Token (FCM)
  // ============================================

  /// ລົງທະບຽນ FCM token
  Future<void> registerDeviceToken({
    required String fcmToken,
    required String platform,
    String? deviceId,
    String? deviceName,
    String? appVersion,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.registerDeviceToken,
      data: {
        'fcmToken': fcmToken,
        'platform': platform,
        if (deviceId != null) 'deviceId': deviceId,
        if (deviceName != null) 'deviceName': deviceName,
        if (appVersion != null) 'appVersion': appVersion,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['message'] ?? 'Failed to register device token',
      );
    }
  }

  /// ລຶບ FCM token
  Future<void> removeDeviceToken(String fcmToken) async {
    await _apiClient.delete(
      ApiConstants.removeDeviceToken,
      data: {'fcmToken': fcmToken},
    );
  }
}
