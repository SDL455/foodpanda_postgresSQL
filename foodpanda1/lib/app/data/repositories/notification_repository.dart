import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationRepository {
  final NotificationProvider _provider = NotificationProvider();

  /// Get paginated list of notifications
  Future<NotificationListResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    return _provider.getNotifications(page: page, limit: limit);
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    return _provider.getUnreadCount();
  }

  /// Mark single notification as read
  Future<bool> markAsRead(String notificationId) async {
    return _provider.markAsRead(notificationId);
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    return _provider.markAllAsRead();
  }

  /// Register FCM token
  Future<bool> registerDeviceToken({
    required String fcmToken,
    required String platform,
    String? deviceId,
    String? deviceName,
    String? appVersion,
  }) async {
    return _provider.registerDeviceToken(
      fcmToken: fcmToken,
      platform: platform,
      deviceId: deviceId,
      deviceName: deviceName,
      appVersion: appVersion,
    );
  }

  /// Unregister FCM token
  Future<bool> unregisterDeviceToken(String fcmToken) async {
    return _provider.unregisterDeviceToken(fcmToken);
  }
}

