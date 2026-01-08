import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../core/constants/app_constants.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.i('Background message received: ${message.messageId}');
  // Handle background message
}

/// Action listener for awesome notifications (must be top-level or static)
@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  final payload = receivedAction.payload;
  if (payload != null) {
    NotificationService.instance._navigateFromNotification(payload);
  }
}

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final _storage = GetStorage();
  final _logger = Logger();
  final _repository = NotificationRepository();

  // Observable values
  final RxInt unreadCount = 0.obs;
  final RxString fcmToken = ''.obs;

  // Notification channel key
  static const String _channelKey = AppConstants.notificationChannelId;

  /// Initialize the notification service
  Future<NotificationService> initialize() async {
    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize awesome notifications
    await _initAwesomeNotifications();

    // Request permission
    await _requestPermission();

    // Get FCM token
    await _getFCMToken();

    // Setup message listeners
    _setupMessageListeners();

    // Get initial unread count
    await refreshUnreadCount();

    return this;
  }

  /// Initialize awesome notifications
  Future<void> _initAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://mipmap/ic_launcher',
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: AppConstants.notificationChannelName,
          channelDescription: AppConstants.notificationChannelDesc,
          defaultColor: const Color(0xFFD70F64),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
        ),
      ],
      debug: false,
    );

    // Set listeners
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onDismissActionReceived,
    );
  }

  /// Notification created callback
  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreated(
      ReceivedNotification receivedNotification) async {
    // Handle notification created
  }

  /// Notification displayed callback
  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayed(
      ReceivedNotification receivedNotification) async {
    // Handle notification displayed
  }

  /// Dismiss action callback
  @pragma('vm:entry-point')
  static Future<void> _onDismissActionReceived(
      ReceivedAction receivedAction) async {
    // Handle dismiss action
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    // Request FCM permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
    );

    _logger.i('FCM permission: ${settings.authorizationStatus}');

    // Request awesome notifications permission
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  /// Get FCM token and register with backend
  Future<void> _getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        _storage.write(AppConstants.fcmTokenKey, token);
        _logger.i('FCM Token: $token');

        // Register token with backend if authenticated
        await registerTokenWithBackend(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        fcmToken.value = newToken;
        _storage.write(AppConstants.fcmTokenKey, newToken);
        await registerTokenWithBackend(newToken);
      });
    } catch (e) {
      _logger.e('Error getting FCM token: $e');
    }
  }

  /// Register FCM token with backend
  Future<void> registerTokenWithBackend(String token) async {
    try {
      // Check if user is authenticated
      if (!_storage.hasData(AppConstants.tokenKey)) {
        return;
      }

      await _repository.registerDeviceToken(
        fcmToken: token,
        platform: Platform.isAndroid ? 'android' : 'ios',
        deviceId: null, // Can add device info package
        deviceName: null,
        appVersion: '1.0.0',
      );
      _logger.i('FCM token registered with backend');
    } catch (e) {
      _logger.e('Error registering FCM token: $e');
    }
  }

  /// Setup message listeners
  void _setupMessageListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // When app is opened from notification (background state)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Check if app was opened from a notification (terminated state)
    _checkInitialMessage();
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logger.i('Foreground message: ${message.notification?.title}');

    // Increment unread count
    unreadCount.value++;

    // Show local notification using awesome notifications
    await _showLocalNotification(message);
  }

  /// Handle notification tap (opens app)
  void _handleNotificationOpen(RemoteMessage message) {
    _logger.i('Notification opened: ${message.data}');
    _navigateFromNotification(
      message.data.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  /// Check if app was opened from notification
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateFromNotification(
        initialMessage.data
            .map((key, value) => MapEntry(key, value.toString())),
      );
    }
  }

  /// Show local notification using awesome notifications
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.hashCode,
        channelKey: _channelKey,
        title: notification.title,
        body: notification.body,
        color: const Color(0xFFD70F64),
        notificationLayout: NotificationLayout.BigText,
        payload:
            message.data.map((key, value) => MapEntry(key, value.toString())),
      ),
    );
  }

  /// Navigate based on notification data
  void _navigateFromNotification(Map<String, String?> data) {
    final type = data['type'];
    final orderId = data['orderId'];
    final notificationId = data['notificationId'];

    // Mark as read if we have notification ID
    if (notificationId != null) {
      markAsRead(notificationId);
    }

    // Navigate based on notification type
    if (type != null) {
      switch (type) {
        case 'ORDER_PLACED':
        case 'ORDER_CONFIRMED':
        case 'ORDER_PREPARING':
        case 'ORDER_READY':
        case 'ORDER_PICKED_UP':
        case 'ORDER_DELIVERING':
        case 'ORDER_DELIVERED':
        case 'ORDER_CANCELLED':
          if (orderId != null) {
            Get.toNamed('/orders/$orderId');
          } else {
            Get.toNamed('/orders');
          }
          break;
        case 'PROMOTION':
          Get.toNamed('/promotions');
          break;
        case 'CHAT_MESSAGE':
          Get.toNamed('/chat');
          break;
        default:
          Get.toNamed('/notifications');
      }
    }
  }

  /// Refresh unread notification count
  Future<void> refreshUnreadCount() async {
    try {
      if (!_storage.hasData(AppConstants.tokenKey)) {
        unreadCount.value = 0;
        return;
      }

      final count = await _repository.getUnreadCount();
      unreadCount.value = count;
    } catch (e) {
      _logger.e('Error getting unread count: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      unreadCount.value = 0;
    } catch (e) {
      _logger.e('Error marking all notifications as read: $e');
    }
  }

  /// Unregister token on logout
  Future<void> unregisterToken() async {
    try {
      final token = _storage.read<String>(AppConstants.fcmTokenKey);
      if (token != null) {
        await _repository.unregisterDeviceToken(token);
      }
    } catch (e) {
      _logger.e('Error unregistering token: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Cancel specific notification by id
  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  /// Get notification icon based on type
  static IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderPlaced:
        return Icons.shopping_bag_outlined;
      case NotificationType.orderConfirmed:
        return Icons.check_circle_outline;
      case NotificationType.orderPreparing:
        return Icons.restaurant_outlined;
      case NotificationType.orderReady:
        return Icons.takeout_dining_outlined;
      case NotificationType.orderPickedUp:
        return Icons.delivery_dining_outlined;
      case NotificationType.orderDelivering:
        return Icons.local_shipping_outlined;
      case NotificationType.orderDelivered:
        return Icons.done_all_outlined;
      case NotificationType.orderCancelled:
        return Icons.cancel_outlined;
      case NotificationType.newOrder:
        return Icons.notification_add_outlined;
      case NotificationType.newDelivery:
        return Icons.two_wheeler_outlined;
      case NotificationType.deliveryAssigned:
        return Icons.assignment_ind_outlined;
      case NotificationType.promotion:
        return Icons.local_offer_outlined;
      case NotificationType.chatMessage:
        return Icons.chat_bubble_outline;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  /// Get notification color based on type
  static Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderPlaced:
        return const Color(0xFF2196F3); // Blue
      case NotificationType.orderConfirmed:
        return const Color(0xFF4CAF50); // Green
      case NotificationType.orderPreparing:
        return const Color(0xFFFF9800); // Orange
      case NotificationType.orderReady:
        return const Color(0xFF9C27B0); // Purple
      case NotificationType.orderPickedUp:
        return const Color(0xFF00BCD4); // Cyan
      case NotificationType.orderDelivering:
        return const Color(0xFF3F51B5); // Indigo
      case NotificationType.orderDelivered:
        return const Color(0xFF4CAF50); // Green
      case NotificationType.orderCancelled:
        return const Color(0xFFF44336); // Red
      case NotificationType.newOrder:
        return const Color(0xFFD70F64); // Pink
      case NotificationType.newDelivery:
        return const Color(0xFFD70F64); // Pink
      case NotificationType.deliveryAssigned:
        return const Color(0xFF607D8B); // Blue Grey
      case NotificationType.promotion:
        return const Color(0xFFFF5722); // Deep Orange
      case NotificationType.chatMessage:
        return const Color(0xFF795548); // Brown
      case NotificationType.system:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}
