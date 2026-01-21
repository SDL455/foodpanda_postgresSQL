import 'package:get/get.dart';
import '../controllers/food_list_controller.dart';

class FoodListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FoodListController>(() => FoodListController());
  }
}
