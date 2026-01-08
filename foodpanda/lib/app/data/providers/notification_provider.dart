import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';
import '../models/notification_model.dart';

class NotificationProvider {
  final ApiService _api = ApiService.to;

  /// Get list of notifications with pagination
  Future<NotificationListResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success'] == true) {
        return NotificationListResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load notifications');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _api.get(ApiEndpoints.notificationsUnreadCount);

      if (response.data['success'] == true) {
        return response.data['data']['count'] as int;
      }
      return 0;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _api.patch(
        ApiEndpoints.notificationRead(notificationId),
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _api.patch(ApiEndpoints.notificationsReadAll);

      return response.data['success'] == true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Register device token for push notifications
  Future<bool> registerDeviceToken({
    required String fcmToken,
    required String platform,
    String? deviceId,
    String? deviceName,
    String? appVersion,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.deviceToken,
        data: {
          'fcmToken': fcmToken,
          'platform': platform,
          'deviceId': deviceId,
          'deviceName': deviceName,
          'appVersion': appVersion,
        },
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Unregister device token (on logout)
  Future<bool> unregisterDeviceToken(String fcmToken) async {
    try {
      final response = await _api.delete(
        ApiEndpoints.deviceToken,
        data: {'fcmToken': fcmToken},
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    String message = 'ເກີດຂໍ້ຜິດພາດ';
    
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        message = data['message'];
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'ການເຊື່ອມຕໍ່ໝົດເວລາ';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'ບໍ່ສາມາດເຊື່ອມຕໍ່ server ໄດ້';
    }

    return Exception(message);
  }
}

