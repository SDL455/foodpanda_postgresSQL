import 'package:foodpanda/pages/auth/bindings/auth_binding.dart';
import 'package:foodpanda/pages/auth/views/login_view.dart';
import 'package:foodpanda/pages/auth/views/register_view.dart';
import 'package:foodpanda/pages/cart/bindings/cart_binding.dart';
import 'package:foodpanda/pages/cart/views/cart_view.dart';
import 'package:foodpanda/pages/checkout/bindings/checkout_binding.dart';
import 'package:foodpanda/pages/checkout/views/checkout_view.dart';
import 'package:foodpanda/pages/food/bindings/food_detail_binding.dart';
import 'package:foodpanda/pages/food/bindings/food_list_binding.dart';
import 'package:foodpanda/pages/food/views/food_detail_view.dart';
import 'package:foodpanda/pages/food/views/food_list_view.dart';
import 'package:foodpanda/pages/main/bindings/main_binding.dart';
import 'package:foodpanda/pages/main/views/main_view.dart';
import 'package:foodpanda/pages/order/bindings/order_history_binding.dart';
import 'package:foodpanda/pages/order/views/order_history_view.dart';
import 'package:foodpanda/pages/profile/bindings/profile_binding.dart';
import 'package:foodpanda/pages/profile/views/profile_view.dart';
import 'package:foodpanda/pages/rider/bindings/rider_binding.dart';
import 'package:foodpanda/pages/rider/views/rider_main_view.dart';
import 'package:foodpanda/pages/splash/bindings/splash_binding.dart';
import 'package:foodpanda/pages/splash/views/splash_view.dart';

// Restaurant pages
import 'package:foodpanda/pages/restaurant/bindings/restaurant_detail_binding.dart';
import 'package:foodpanda/pages/restaurant/views/restaurant_detail_view.dart';

// New pages
import 'package:foodpanda/pages/address/bindings/address_binding.dart';
import 'package:foodpanda/pages/address/views/address_list_view.dart';
import 'package:foodpanda/pages/favorites/bindings/favorites_binding.dart';
import 'package:foodpanda/pages/favorites/views/favorites_view.dart';
import 'package:foodpanda/pages/notifications/bindings/notifications_binding.dart';
import 'package:foodpanda/pages/notifications/views/notifications_view.dart';
import 'package:foodpanda/pages/search/bindings/search_binding.dart';
import 'package:foodpanda/pages/search/views/search_view.dart';

import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // Auth
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),

    // Customer Main (with bottom navigation)
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),

    // Cart
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),

    // Checkout
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),

    // Restaurant Detail
    GetPage(
      name: AppRoutes.restaurantDetail,
      page: () => const RestaurantDetailView(),
      binding: RestaurantDetailBinding(),
    ),

    // Food List
    GetPage(
      name: AppRoutes.foods,
      page: () => const FoodListView(),
      binding: FoodListBinding(),
    ),

    // Food Detail
    GetPage(
      name: AppRoutes.foodDetail,
      page: () => const FoodDetailView(),
      binding: FoodDetailBinding(),
    ),

    // Orders
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderHistoryView(),
      binding: OrderHistoryBinding(),
    ),

    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),

    // Addresses
    GetPage(
      name: AppRoutes.addresses,
      page: () => const AddressListView(),
      binding: AddressBinding(),
    ),

    // Favorites
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),

    // Notifications
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),

    // Search (Foods)
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),

    // Rider Main
    GetPage(
      name: AppRoutes.riderMain,
      page: () => const RiderMainView(),
      binding: RiderBinding(),
    ),
  ];
}
