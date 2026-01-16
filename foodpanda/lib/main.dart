import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodpanda/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/storage_service.dart';
import 'core/network/api_client.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService.init();

  // Initialize API client
  ApiClient().init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const FoodPandaApp());
}

class FoodPandaApp extends StatelessWidget {
  const FoodPandaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'FoodPanda',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,

          // Localization
          locale: const Locale('lo', 'LA'),
          fallbackLocale: const Locale('en', 'US'),

          // Routes
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,

          // Global bindings
          initialBinding: BindingsBuilder(() {
            Get.put(AuthController(), permanent: true);
          }),

          // Default transition
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
