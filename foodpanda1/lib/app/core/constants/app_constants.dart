// App Constants
class AppConstants {
  AppConstants._();

  // API Base URL
  static const String baseUrl = 'http://localhost:3000/api';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String fcmTokenKey = 'fcm_token';
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';

  // Notification Channel
  static const String notificationChannelId = 'foodpanda_notifications';
  static const String notificationChannelName = 'Foodpanda Notifications';
  static const String notificationChannelDesc =
      'Notifications for orders and updates';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

// API Endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String socialAuth = '/mobile/auth/social';

  // Device Token
  static const String deviceToken = '/mobile/device-token';

  // Notifications
  static const String notifications = '/mobile/notifications';
  static String notificationRead(String id) => '/mobile/notifications/$id/read';
  static const String notificationsReadAll = '/mobile/notifications/read-all';
  static const String notificationsUnreadCount =
      '/mobile/notifications/unread-count';

  // Stores
  static const String stores = '/mobile/stores';
  static String storeDetail(String id) => '/mobile/stores/$id';

  // Orders
  static const String orders = '/mobile/orders';
  static String orderDetail(String id) => '/mobile/orders/$id';
}
