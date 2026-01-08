import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/notifications/bindings/notification_binding.dart';
import '../modules/notifications/views/notification_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = <GetPage>[
    // Splash Screen
    GetPage(
      name: Routes.splash,
      page: () => const _SplashPage(),
    ),

    // Notifications
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationPage(),
      binding: NotificationBinding(),
      transition: Transition.rightToLeft,
    ),

    // TODO: Add more routes as needed
    // Home, Orders, Profile, etc.
  ];
}

// Temporary splash page - replace with actual splash screen
class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Foodpanda Clone'),
      ),
    );
  }
}
