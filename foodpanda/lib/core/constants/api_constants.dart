import 'dart:io';

class ApiConstants {
  ApiConstants._();

  // Base URL - ປ່ຽນເປັນ IP ຂອງ computer ທ່ານ ຖ້າໃຊ້ device ຈິງ
  // ສຳລັບ Android Emulator: ໃຊ້ 10.0.2.2 ແທນ localhost
  // ສຳລັບ iOS Simulator: ໃຊ້ localhost
  // ສຳລັບ Device ຈິງ: ໃຊ້ IP address ຂອງ computer (ຕົວຢ່າງ: 192.168.1.100)
  // ປ່ຽນ IP ນີ້ເປັນ IP ຂອງຄອມພິວເຕີທ່ານ ຖ້າໃຊ້ device ຈິງ
  static const String _deviceIp = '192.168.100.38';

  // ຕັ້ງເປັນ true ຖ້າໃຊ້ device ຈິງ, false ຖ້າໃຊ້ emulator
  static const bool _useRealDevice = false;

  /// Server base URL (ບໍ່ມີ /api) - ໃຊ້ສຳລັບໂຫຼດຮູບພາບ
  static String get serverUrl {
    if (Platform.isAndroid) {
      if (_useRealDevice) {
        return 'http://$_deviceIp:3000';
      } else {
        return 'http://10.0.2.2:3000';
      }
    } else if (Platform.isIOS) {
      if (_useRealDevice) {
        return 'http://$_deviceIp:3000';
      } else {
        return 'http://localhost:3000';
      }
    } else {
      return 'http://localhost:3000';
    }
  }

  /// API base URL (ມີ /api)
  static String get baseUrl => '$serverUrl/api';

  /// ແປງ image URL ຈາກ relative ເປັນ absolute
  /// ຕົວຢ່າງ: /uploads/image.jpg -> http://10.0.2.2:3000/uploads/image.jpg
  static String getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'https://via.placeholder.com/300x200?text=No+Image';
    }

    // ຖ້າເປັນ URL ເຕັມແລ້ວ (http:// ຫຼື https://) ສົ່ງກັບຄືນໂດຍຕົງ
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // ຖ້າເປັນ relative path, ເພີ່ມ server URL
    if (imageUrl.startsWith('/')) {
      return '$serverUrl$imageUrl';
    }

    return '$serverUrl/$imageUrl';
  }

  // Auth Endpoints (Mobile)
  static const String socialAuth = '/mobile/auth/social';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String googleAuth = '/mobile/auth/social';

  // Rider Auth Endpoints
  static const String riderLogin = '/auth/rider/login';
  static const String riderProfile = '/rider/profile';

  // User/Customer Endpoints
  static const String profile = '/mobile/customer/profile';
  static const String updateProfile = '/mobile/customer/profile';
  static const String addresses = '/mobile/customer/addresses';

  // Store/Restaurant Endpoints
  static const String stores = '/mobile/stores';
  static const String storeDetail = '/mobile/stores/'; // + id
  static const String categories = '/categories';
  static const String popularStores = '/mobile/stores?sort=popular';
  static const String nearbyStores = '/mobile/stores?sort=nearby';
  static const String searchStores = '/mobile/stores?search=';

  // Menu/Product Endpoints
  static const String products = '/mobile/products';
  static const String productDetail = '/mobile/products/'; // + id
  static const String productsByStore = '/stores/'; // + id + /products

  // Cart Endpoints
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String updateCart = '/cart/update';
  static const String removeFromCart = '/cart/remove';
  static const String clearCart = '/cart/clear';

  // Order Endpoints
  static const String orders = '/mobile/orders';
  static const String createOrder = '/mobile/orders';
  static const String orderDetail = '/orders/'; // + id
  static const String activeOrders = '/orders?status=active';
  static const String orderHistory = '/orders?status=history';
  static const String cancelOrder = '/orders/cancel';
  static const String trackOrder = '/orders/'; // + id

  // Payment Endpoints
  static const String paymentMethods = '/payments/methods';
  static const String createPaymentIntent = '/payments/create-intent';
  static const String confirmPayment = '/payments/confirm';

  // Review Endpoints
  static const String reviews = '/reviews';
  static const String addReview = '/reviews/add';

  // Notification Endpoints
  static const String notifications = '/mobile/notifications';
  static const String notificationUnreadCount =
      '/mobile/notifications/unread-count';
  static const String markNotificationRead =
      '/mobile/notifications/'; // + id + /read
  static const String markAllNotificationsRead =
      '/mobile/notifications/read-all';
  static const String registerDeviceToken = '/mobile/device-token';
  static const String removeDeviceToken = '/mobile/device-token';

  // Favorites Endpoints
  static const String favorites = '/mobile/customer/favorites';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
