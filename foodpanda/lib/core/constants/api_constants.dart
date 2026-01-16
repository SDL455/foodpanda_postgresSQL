import 'dart:io';

class ApiConstants {
  ApiConstants._();

  // Base URL - ປ່ຽນເປັນ IP ຂອງ computer ທ່ານ ຖ້າໃຊ້ device ຈິງ
  // ສຳລັບ Android Emulator: ໃຊ້ 10.0.2.2 ແທນ localhost
  // ສຳລັບ iOS Simulator: ໃຊ້ localhost
  // ສຳລັບ Device ຈິງ: ໃຊ້ IP address ຂອງ computer (ຕົວຢ່າງ: 192.168.1.100)
  static String get baseUrl {
    // ກວດເບິ່ງວ່າແມ່ນ Android ບໍ່
    if (Platform.isAndroid) {
      // ສຳລັບ Android Emulator ໃຊ້ 10.0.2.2
      // ຖ້າໃຊ້ device ຈິງ, ປ່ຽນເປັນ IP ຂອງ computer ທ່ານ
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      // ສຳລັບ iOS Simulator ໃຊ້ localhost
      return 'http://localhost:3000/api';
    } else {
      // Desktop/Web
      return 'http://localhost:3000/api';
    }
  }

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String googleAuth = '/auth/google';

  // User Endpoints
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String addresses = '/users/addresses';

  // Restaurant Endpoints
  static const String restaurants = '/restaurants';
  static const String restaurantDetail = '/restaurants/'; // + id
  static const String categories = '/categories';
  static const String popularRestaurants = '/restaurants/popular';
  static const String nearbyRestaurants = '/restaurants/nearby';
  static const String searchRestaurants = '/restaurants/search';

  // Menu Endpoints
  static const String menuItems = '/menu-items';
  static const String menuByRestaurant = '/restaurants/'; // + id + /menu

  // Cart Endpoints
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String updateCart = '/cart/update';
  static const String removeFromCart = '/cart/remove';
  static const String clearCart = '/cart/clear';

  // Order Endpoints
  static const String orders = '/orders';
  static const String createOrder = '/orders/create';
  static const String orderDetail = '/orders/'; // + id
  static const String activeOrders = '/orders/active';
  static const String orderHistory = '/orders/history';
  static const String cancelOrder = '/orders/cancel';
  static const String trackOrder = '/orders/track/'; // + id

  // Payment Endpoints
  static const String paymentMethods = '/payments/methods';
  static const String createPaymentIntent = '/payments/create-intent';
  static const String confirmPayment = '/payments/confirm';

  // Review Endpoints
  static const String reviews = '/reviews';
  static const String addReview = '/reviews/add';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String registerFCM = '/notifications/register';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
