import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../order/controllers/order_history_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MainController>()) {
      Get.put<MainController>(MainController(), permanent: true);
    }
    Get.lazyPut<HomeController>(() => HomeController());
    if (!Get.isRegistered<CartController>()) {
      Get.put<CartController>(CartController(), permanent: true);
    }
    Get.lazyPut<OrderHistoryController>(() => OrderHistoryController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
