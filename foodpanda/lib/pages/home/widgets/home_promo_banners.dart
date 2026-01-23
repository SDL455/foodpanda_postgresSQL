import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../widgets/promo_banner.dart';
import '../controllers/home_controller.dart';

class HomePromoBanners extends GetView<HomeController> {
  const HomePromoBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final banners = controller.promoBanners.toList();
      if (banners.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: PromoBannerCarousel(
          banners: banners,
          onBannerTap: (banner) {
            // Handle banner tap
          },
        ),
      );
    });
  }
}
