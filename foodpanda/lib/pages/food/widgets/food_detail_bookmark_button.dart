import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/food_detail_controller.dart';

class FoodDetailBookmarkButton extends GetView<FoodDetailController> {
  const FoodDetailBookmarkButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Obx(() {
        final isFavorite = controller.isFavorite.value;
        final isLoading = controller.isFavoriteLoading.value;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: IconButton(
            icon: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: isFavorite
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
            onPressed: isLoading ? null : controller.toggleFavorite,
          ),
        );
      }),
    );
  }
}
