import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/storage_service.dart';
import '../../data/repositories/rider_repository.dart';
import '../../pages/rider/controllers/rider_notification_controller.dart';
import '../../pages/rider/controllers/rider_delivery_controller.dart';

/// Service ສຳລັບຈັດການ push notifications ສຳລັບ rider
class RiderNotificationService {
  static final RiderNotificationService _instance =
      RiderNotificationService._internal();
  factory RiderNotificationService() => _instance;
  RiderNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final RiderRepository _repository = RiderRepository();

  /// Initialize notification service
  Future<void> init() async {
    // Initialize awesome notifications
    await _initAwesomeNotifications();

    // Request permission
    await _requestPermission();

    // Get FCM token and register
    await _registerToken();

    // Setup message handlers
    _setupMessageHandlers();
  }

  /// Initialize awesome notifications
  Future<void> _initAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // Use default app icon
      [
        NotificationChannel(
          channelKey: 'rider_delivery',
          channelName: 'ງານສົ່ງ',
          channelDescription: 'ແຈ້ງເຕືອນເມື່ອມີງານສົ່ງໃໝ່',
          defaultColor: const Color(0xFFE21A72),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'rider_general',
          channelName: 'ທົ່ວໄປ',
          channelDescription: 'ແຈ້ງເຕືອນທົ່ວໄປ',
          defaultColor: const Color(0xFFE21A72),
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
        ),
      ],
    );

    // Setup notification action listener
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      'Rider notification permission: ${settings.authorizationStatus}',
    );
  }

  /// Register FCM token
  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await StorageService.setFcmToken(token);

        // Register token to backend
        await _repository.registerDeviceToken(
          fcmToken: token,
          platform: Platform.isAndroid ? 'android' : 'ios',
        );

        debugPrint('Rider FCM token registered: ${token.substring(0, 20)}...');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        await StorageService.setFcmToken(newToken);
        await _repository.registerDeviceToken(
          fcmToken: newToken,
          platform: Platform.isAndroid ? 'android' : 'ios',
        );
        debugPrint('Rider FCM token refreshed');
      });
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app launched from notification)
    _checkInitialMessage();
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Rider foreground message: ${message.notification?.title}');

    final data = message.data;
    final type = data['type'] as String?;

    // Show local notification
    _showLocalNotification(message);

    // Handle based on type
    if (type == 'NEW_DELIVERY' || type == 'DELIVERY_ASSIGNED') {
      _handleNewDeliveryNotification(data);
    }

    // Update notification controller
    _updateNotificationController(data);
  }

  /// Handle message opened (user tapped notification)
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Rider notification tapped: ${message.notification?.title}');

    final data = message.data;
    final type = data['type'] as String?;

    if (type == 'NEW_DELIVERY' || type == 'DELIVERY_ASSIGNED') {
      // Navigate to home and refresh deliveries
      Get.offAllNamed('/rider');
      _handleNewDeliveryNotification(data);
    } else if (data['orderId'] != null) {
      // Navigate to delivery detail
      Get.toNamed('/rider/delivery/${data['orderId']}');
    }
  }

  /// Check for initial message
  Future<void> _checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      debugPrint('Rider initial message: ${message.notification?.title}');
      // Delay to ensure app is ready
      await Future.delayed(const Duration(seconds: 1));
      _handleMessageOpenedApp(message);
    }
  }

  /// Show local notification using awesome notifications
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    final type = data['type'] as String?;

    // Determine channel
    final channelKey = (type == 'NEW_DELIVERY' || type == 'DELIVERY_ASSIGNED')
        ? 'rider_delivery'
        : 'rider_general';

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey,
        title: notification?.title ?? data['title'] ?? 'ແຈ້ງເຕືອນ',
        body: notification?.body ?? data['body'] ?? '',
        notificationLayout: NotificationLayout.Default,
        payload: data.map((k, v) => MapEntry(k, v.toString())),
        category: type == 'NEW_DELIVERY'
            ? NotificationCategory.Message
            : NotificationCategory.Status,
      ),
      actionButtons: type == 'NEW_DELIVERY'
          ? [
              NotificationActionButton(
                key: 'VIEW',
                label: 'ເບິ່ງ',
              ),
            ]
          : null,
    );
  }

  /// Handle new delivery notification
  void _handleNewDeliveryNotification(Map<String, dynamic> data) {
    // Refresh deliveries list
    if (Get.isRegistered<RiderDeliveryController>()) {
      final controller = Get.find<RiderDeliveryController>();
      controller.handleNewDeliveryNotification(data);
    }
  }

  /// Update notification controller
  void _updateNotificationController(Map<String, dynamic> data) {
    if (Get.isRegistered<RiderNotificationController>()) {
      final controller = Get.find<RiderNotificationController>();
      controller.handlePushNotification(data);
    }
  }

  /// Remove FCM token (on logout)
  Future<void> removeToken() async {
    try {
      final token = StorageService.fcmToken;
      if (token != null) {
        await _repository.removeDeviceToken(token);
      }
      await _messaging.deleteToken();
      debugPrint('Rider FCM token removed');
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  // Awesome notification callbacks
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('Notification action: ${receivedAction.buttonKeyPressed}');

    if (receivedAction.buttonKeyPressed == 'VIEW') {
      // Navigate to rider home
      Get.offAllNamed('/rider');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification created: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification displayed: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('Notification dismissed');
  }
}
