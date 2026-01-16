import 'package:foodpanda/modules/auth/bindings/auth_binding.dart';
import 'package:foodpanda/modules/auth/views/login_view.dart';
import 'package:foodpanda/modules/auth/views/register_view.dart';
import 'package:foodpanda/modules/cart/bindings/cart_binding.dart';
import 'package:foodpanda/modules/cart/views/cart_view.dart';
import 'package:foodpanda/modules/main/bindings/main_binding.dart';
import 'package:foodpanda/modules/main/views/main_view.dart';
import 'package:foodpanda/modules/order/bindings/order_binding.dart';
import 'package:foodpanda/modules/order/views/order_list_view.dart';
import 'package:foodpanda/modules/profile/bindings/profile_binding.dart';
import 'package:foodpanda/modules/profile/views/profile_view.dart';
import 'package:foodpanda/modules/rider/bindings/rider_binding.dart';
import 'package:foodpanda/modules/rider/views/rider_main_view.dart';
import 'package:foodpanda/modules/splash/bindings/splash_binding.dart';
import 'package:foodpanda/modules/splash/views/splash_view.dart';
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

    // Orders
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderListView(),
      binding: OrderBinding(),
    ),

    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),

    // Rider Main
    GetPage(
      name: AppRoutes.riderMain,
      page: () => const RiderMainView(),
      binding: RiderBinding(),
    ),
  ];
}
