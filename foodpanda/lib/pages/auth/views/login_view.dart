import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_logo.dart';
import '../widgets/forgot_password_button.dart';
import '../widgets/google_icon.dart';
import '../widgets/or_divider.dart';
import '../widgets/register_link.dart';
import '../widgets/user_type_toggle.dart';
import '../widgets/welcome_text.dart';

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
                SizedBox(height: 40.h),
                // User Type Toggle
                const UserTypeToggle(),
                SizedBox(height: 30.h),
                // Logo
                const AuthLogo(),
                SizedBox(height: 30.h),
                // Welcome text
                const WelcomeText(),
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
                const ForgotPasswordButton(),
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
                // Divider and Google sign in (only for customer)
                Obx(
                  () => controller.isRiderLogin.value
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            const OrDivider(),
                            SizedBox(height: 24.h),
                            CustomButton(
                              text: AppStrings.continueWithGoogle,
                              onPressed: () {},
                              isLoading: controller.isLoading.value,
                              isOutlined: true,
                              icon: const GoogleIcon(),
                            ),
                          ],
                        ),
                ),
                SizedBox(height: 32.h),
                // Register link (only for customer)
                const RegisterLink(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
