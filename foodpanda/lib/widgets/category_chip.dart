import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_colors.dart';
import '../data/models/category_model.dart';
import 'cached_image.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Image
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: category.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: CachedImage(
                        imageUrl: category.image!,
                        width: 40.w,
                        height: 40.w,
                      ),
                    )
                  : Icon(
                      _getCategoryIcon(category.name),
                      color: isSelected ? AppColors.primary : AppColors.grey500,
                      size: 24.sp,
                    ),
            ),
            SizedBox(height: 8.h),
            // Name
            Text(
              category.name,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('burger') || nameLower.contains('ເບີເກີ')) {
      return Icons.lunch_dining;
    } else if (nameLower.contains('pizza') || nameLower.contains('ພິດຊ່າ')) {
      return Icons.local_pizza;
    } else if (nameLower.contains('coffee') || nameLower.contains('ກາເຟ')) {
      return Icons.coffee;
    } else if (nameLower.contains('dessert') || nameLower.contains('ຂອງຫວານ')) {
      return Icons.cake;
    } else if (nameLower.contains('drink') || nameLower.contains('ເຄື່ອງດື່ມ')) {
      return Icons.local_drink;
    } else if (nameLower.contains('noodle') || nameLower.contains('ເຝີ')) {
      return Icons.ramen_dining;
    } else if (nameLower.contains('rice') || nameLower.contains('ເຂົ້າ')) {
      return Icons.rice_bowl;
    } else {
      return Icons.restaurant;
    }
  }
}
