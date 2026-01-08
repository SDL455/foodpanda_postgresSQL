import 'package:get/get.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core services - permanent
    Get.put<ApiService>(ApiService(), permanent: true);
    
    // Notification service is already initialized in main.dart
    // Just ensure it's findable
    if (!Get.isRegistered<NotificationService>()) {
      Get.put<NotificationService>(NotificationService(), permanent: true);
    }
  }
}

