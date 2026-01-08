part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  // Main Routes
  static const splash = '/splash';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  
  // Notifications
  static const notifications = '/notifications';
  
  // Orders
  static const orders = '/orders';
  static const orderDetail = '/orders/:id';
  
  // Stores
  static const stores = '/stores';
  static const storeDetail = '/stores/:id';
  
  // Profile
  static const profile = '/profile';
  static const settings = '/settings';
  
  // Cart
  static const cart = '/cart';
  static const checkout = '/checkout';
  
  // Chat
  static const chat = '/chat';
  
  // Promotions
  static const promotions = '/promotions';
}

