import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/utils/storage_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    debugPrint('>>> SplashController onInit called');
    _initApp();
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('>>> SplashController onReady called');
  }

  Future<void> _initApp() async {
    debugPrint('>>> _initApp started');

    await Future.delayed(const Duration(seconds: 2));

    debugPrint('>>> Delay finished, checking login status...');
    debugPrint('>>> isLoggedIn = ${StorageService.isLoggedIn}');
    debugPrint('>>> userType = ${StorageService.userType}');

    try {
      if (StorageService.isLoggedIn) {
        // ກວດເບິ່ງປະເພດຜູ້ໃຊ້ ແລ້ວນຳທາງໄປໜ້າທີ່ຖືກຕ້ອງ
        if (StorageService.isRider) {
          debugPrint('>>> Navigating to rider main');
          Get.offAllNamed(AppRoutes.riderMain);
        } else {
          debugPrint('>>> Navigating to customer main');
        Get.offAllNamed(AppRoutes.main);
        }
      } else {
        debugPrint('>>> Navigating to login');
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('>>> Navigation error: $e');
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
