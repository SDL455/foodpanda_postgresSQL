import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';
import '../../../core/utils/storage_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  // User type selection (customer or rider)
  final RxBool isRiderLogin = false.obs;

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  // Toggle between customer and rider login
  void toggleUserType() {
    isRiderLogin.value = !isRiderLogin.value;
  }

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _authRepository.currentUser;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // Login
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      if (isRiderLogin.value) {
        // Rider Login
        await _authRepository.riderLogin(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
        await StorageService.setUserType('rider');
        _clearForm();
        Get.offAllNamed(AppRoutes.riderMain);
      } else {
        // Customer Login
        final user = await _authRepository.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
        await StorageService.setUserType('customer');
        currentUser.value = user;
        _clearForm();
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      LoggerService.error('Login error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: e.toString(),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Register
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: 'ລະຫັດຜ່ານບໍ່ກົງກັນ',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;

      final user = await _authRepository.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
      );

      await StorageService.setUserType('customer');
      currentUser.value = user;
      _clearForm();
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      LoggerService.error('Register error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: e.toString(),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Google Sign In
  // Future<void> googleSignIn() async {
  //   try {
  //     isLoading.value = true;

  //     final GoogleSignIn googleSignIn = GoogleSignIn(
  //       scopes: ['email', 'profile'],
  //     );

  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //     if (googleUser == null) {
  //       isLoading.value = false;
  //       return;
  //     }

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     if (googleAuth.idToken == null) {
  //       throw Exception('ບໍ່ສາມາດຮັບ token ຈາກ Google ໄດ້');
  //     }

  //     final user = await _authRepository.googleSignIn(
  //       idToken: googleAuth.idToken!,
  //     );

  //     currentUser.value = user;
  //     Get.offAllNamed(AppRoutes.main);
  //   } catch (e) {
  //     LoggerService.error('Google sign in error', e);
  //     Helpers.showSnackbar(
  //       title: 'ເກີດຂໍ້ຜິດພາດ',
  //       message: e.toString(),
  //       isError: true,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Logout
  Future<void> logout() async {
    final confirm = await Helpers.showConfirmDialog(
      title: 'ອອກຈາກລະບົບ',
      message: 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?',
    );

    if (!confirm) return;

    Helpers.showLoading(message: 'ກຳລັງອອກຈາກລະບົບ...');

    await _authRepository.logout();
    currentUser.value = null;

    Helpers.hideLoading();
    Get.offAllNamed(AppRoutes.login);
  }

  // Forgot password
  Future<void> forgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: 'ກະລຸນາໃສ່ອີເມວ',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _authRepository.forgotPassword(email: emailController.text.trim());
      Helpers.showSnackbar(
        title: 'ສຳເລັດ',
        message: 'ກະລຸນາກວດສອບອີເມວຂອງທ່ານ',
      );
    } catch (e) {
      LoggerService.error('Forgot password error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: e.toString(),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    phoneController.clear();
  }

  // Validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາໃສ່ອີເມວ';
    }
    if (!Helpers.isValidEmail(value)) {
      return 'ອີເມວບໍ່ຖືກຕ້ອງ';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາໃສ່ລະຫັດຜ່ານ';
    }
    if (value.length < 6) {
      return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາໃສ່ຊື່';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    if (!Helpers.isValidPhone(value)) {
      return 'ເບີໂທບໍ່ຖືກຕ້ອງ';
    }
    return null;
  }
}
