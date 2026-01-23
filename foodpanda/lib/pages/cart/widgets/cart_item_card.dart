import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../widgets/cached_image.dart';
import 'cart_quantity_controls.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final Function(String) onRemove;
  final Function(String, int) onUpdateQuantity;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onRemove(item.id),
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            icon: Icons.delete,
            label: AppStrings.delete,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedImage(
              imageUrl: ApiConstants.getImageUrl(item.menuItem.image),
              width: 60.w,
              height: 60.w,
              borderRadius: 8.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menuItem.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      item.note!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Text(
                    Helpers.formatCurrency(item.totalPrice),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            CartQuantityControls(
              quantity: item.quantity,
              onDecrease: () => onUpdateQuantity(item.id, item.quantity - 1),
              onIncrease: () => onUpdateQuantity(item.id, item.quantity + 1),
            ),
          ],
        ),
      ),
    );
  }
}
