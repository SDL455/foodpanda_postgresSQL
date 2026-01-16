import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../core/utils/storage_service.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final Rxn<UserModel> user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    final userData = StorageService.userData;
    if (userData != null) {
      user.value = UserModel.fromJson(userData);
    }
  }

  void logout() {
    Get.find<AuthController>().logout();
  }
}
