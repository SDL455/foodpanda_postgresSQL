import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60.h),
                // Logo
                _buildLogo(),
                SizedBox(height: 40.h),
                // Welcome text
                Text(
                  'ຍິນດີຕ້ອນຮັບກັບຄືນ!',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'ເຂົ້າສູ່ລະບົບເພື່ອສັ່ງອາຫານ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 32.h),
                // Email field
                CustomTextField(
                  controller: controller.emailController,
                  label: AppStrings.email,
                  hint: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: controller.validateEmail,
                ),
                SizedBox(height: 16.h),
                // Password field
                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    label: AppStrings.password,
                    hint: '••••••••',
                    obscureText: controller.obscurePassword.value,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: controller.obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixTap: controller.togglePasswordVisibility,
                    validator: controller.validatePassword,
                  ),
                ),
                SizedBox(height: 8.h),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.forgotPassword,
                    child: Text(
                      AppStrings.forgotPassword,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                // Login button
                Obx(
                  () => CustomButton(
                    text: AppStrings.login,
                    onPressed: controller.login,
                    isLoading: controller.isLoading.value,
                  ),
                ),
                SizedBox(height: 24.h),
                // Divider
                _buildDivider(),
                SizedBox(height: 24.h),
                // Google sign in
                Obx(
                  () => CustomButton(
                    text: AppStrings.continueWithGoogle,
                    // onPressed: controller.googleSignIn,
                    onPressed: () {},
                    isLoading: controller.isLoading.value,
                    isOutlined: true,
                    icon: _buildGoogleIcon(),
                  ),
                ),
                SizedBox(height: 32.h),
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      child: Text(
                        AppStrings.register,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Icon(Icons.restaurant_menu, size: 40.sp, color: AppColors.white),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.grey300)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            AppStrings.orContinueWith,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
          ),
        ),
        Expanded(child: Divider(color: AppColors.grey300)),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24.w,
      height: 24.w,
      margin: EdgeInsets.only(right: 8.w),
      child: Icon(Icons.g_mobiledata, size: 24.sp, color: AppColors.primary),
    );
  }
}
