import 'package:get/get.dart';
import '../controllers/rider_controller.dart';
import '../controllers/rider_delivery_controller.dart';

class RiderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiderController>(() => RiderController());
    Get.lazyPut<RiderDeliveryController>(() => RiderDeliveryController());
  }
}
