import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                // Title
                Text(
                  'ສ້າງບັນຊີໃໝ່',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'ກະລຸນາໃສ່ຂໍ້ມູນຂອງທ່ານ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 32.h),
                // Name field
                CustomTextField(
                  controller: controller.nameController,
                  label: 'ຊື່',
                  hint: 'ໃສ່ຊື່ຂອງທ່ານ',
                  prefixIcon: Icons.person_outline,
                  validator: controller.validateName,
                ),
                SizedBox(height: 16.h),
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
                // Phone field
                CustomTextField(
                  controller: controller.phoneController,
                  label: '${AppStrings.phoneNumber} (ບໍ່ບັງຄັບ)',
                  hint: '20XXXXXXXX',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: controller.validatePhone,
                ),
                SizedBox(height: 16.h),
                // Password field
                Obx(() => CustomTextField(
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
                    )),
                SizedBox(height: 16.h),
                // Confirm password field
                Obx(() => CustomTextField(
                      controller: controller.confirmPasswordController,
                      label: AppStrings.confirmPassword,
                      hint: '••••••••',
                      obscureText: controller.obscureConfirmPassword.value,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: controller.obscureConfirmPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      onSuffixTap: controller.toggleConfirmPasswordVisibility,
                      validator: controller.validatePassword,
                    )),
                SizedBox(height: 32.h),
                // Register button
                Obx(() => CustomButton(
                      text: AppStrings.register,
                      onPressed: controller.register,
                      isLoading: controller.isLoading.value,
                    )),
                SizedBox(height: 24.h),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        AppStrings.login,
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
}
