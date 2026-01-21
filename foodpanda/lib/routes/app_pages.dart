import 'package:foodpanda/pages/auth/bindings/auth_binding.dart';
import 'package:foodpanda/pages/auth/views/login_view.dart';
import 'package:foodpanda/pages/auth/views/register_view.dart';
import 'package:foodpanda/pages/cart/bindings/cart_binding.dart';
import 'package:foodpanda/pages/cart/views/cart_view.dart';
import 'package:foodpanda/pages/food/bindings/food_detail_binding.dart';
import 'package:foodpanda/pages/food/bindings/food_list_binding.dart';
import 'package:foodpanda/pages/food/views/food_detail_view.dart';
import 'package:foodpanda/pages/food/views/food_list_view.dart';
import 'package:foodpanda/pages/main/bindings/main_binding.dart';
import 'package:foodpanda/pages/main/views/main_view.dart';
import 'package:foodpanda/pages/order/bindings/order_binding.dart';
import 'package:foodpanda/pages/order/views/order_list_view.dart';
import 'package:foodpanda/pages/profile/bindings/profile_binding.dart';
import 'package:foodpanda/pages/profile/views/profile_view.dart';
import 'package:foodpanda/pages/rider/bindings/rider_binding.dart';
import 'package:foodpanda/pages/rider/views/rider_main_view.dart';
import 'package:foodpanda/pages/splash/bindings/splash_binding.dart';
import 'package:foodpanda/pages/splash/views/splash_view.dart';
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
