import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import '../../model/restaurent_details_model.dart';
import 'food_details_bottom_sheet.dart';
import 'quantity_control_widget.dart';

class FoodWidget extends StatelessWidget {
  final Food foodItem;

  const FoodWidget({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RestaurantDetailViewController>();
    final hasCustomizations = foodItem.customizations != null && foodItem.customizations!.isNotEmpty;

    return Container(
      width: context.wp(100),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              onTap: () => _showFoodBottomSheet(context, foodItem, isEdit: false),
              child: image(
                url: foodItem.foodImage ?? '',
                height: 120,
                width: context.wp(100),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          10.h,
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showFoodBottomSheet(context, foodItem, isEdit: false),
                  child: text(
                    text: foodItem.foodName ?? '',
                    size: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColor.black,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          8.h,
          Row(
            children: [
              text(
                text: '₹ ${(foodItem.discountPrice ?? foodItem.foodPrice ?? 0).toInt()}',
                size: 16,
                fontWeight: FontWeight.w600,
              ),
              if (foodItem.discountPrice != null &&
                  foodItem.discountPrice != foodItem.actualPrice &&
                  foodItem.actualPrice != null) ...[
                8.w,
                text(
                  text: '₹ ${foodItem.actualPrice?.toInt()}',
                  size: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColor.black.withOpacity(0.2),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColor.black.withOpacity(0.2),
                ),
              ],
            ],
          ),
          8.h,
          if (!hasCustomizations)
            // SCENARIO A: Simple quantity control or add button
            GetBuilder<RestaurantDetailViewController>(
              id: 'food_grid',
              builder: (controller) {
                final quantity = controller.getFoodQuantity(foodItem.foodId ?? '');
                return quantity > 0
                    ? QuantityControlWidget(
                      quantity: quantity,
                      onIncrease: () {
                        debugPrint('🍔 Increasing qty for ${foodItem.foodName}');
                        controller.increaseFoodQuantity(foodItem.foodId ?? '');
                      },
                      onDecrease: () {
                        debugPrint('🍔 Decreasing qty for ${foodItem.foodName}');
                        controller.decreaseFoodQuantity(foodItem.foodId ?? '');
                      },
                      showRemoveButton: quantity > 0,
                      buttonSize: 28,
                      iconSize: 14,
                    )
                    : GestureDetector(
                      onTap: () {
                        debugPrint('🍔 Increasing qty for ${foodItem.foodName}');
                        controller.increaseFoodQuantity(foodItem.foodId ?? '');
                      },
                      child: Container(
                        width: context.wp(100),
                        height: 28,
                        decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
                        child: Center(
                          child: text(text: 'Add', size: 14, fontWeight: FontWeight.w500, color: AppColor.white),
                        ),
                      ),
                    );
              },
            )
          else
            // SCENARIO B & C: Show + button for add, or edit icon if in cart
            GetBuilder<RestaurantDetailViewController>(
              id: 'food_grid',
              builder: (controller) {
                final isInCart = controller.isFoodInCart(foodItem.foodId ?? '');

                if (isInCart) {
                  // Show edit icon for items already in cart
                  return GestureDetector(
                    onTap: () {
                      debugPrint('✏️ Edit button tapped for ${foodItem.foodName}');
                      _showFoodBottomSheet(context, foodItem, isEdit: true);
                    },
                    child: Container(
                      width: context.wp(100),
                      height: 28,
                      decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
                      child: Center(
                        child: text(text: 'edit', size: 14, fontWeight: FontWeight.w500, color: AppColor.white),
                      ),
                    ),
                  );
                } else {
                  // Show add button for new items
                  return GestureDetector(
                    onTap: () {
                      debugPrint('🔵 Add button tapped for ${foodItem.foodName}');
                      _showFoodBottomSheet(context, foodItem, isEdit: false);
                    },
                    child: Container(
                      width: context.wp(100),
                      height: 28,
                      decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
                      child: Center(
                        child: text(text: 'Add', size: 14, fontWeight: FontWeight.w500, color: AppColor.white),
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  void _showFoodBottomSheet(BuildContext context, Food foodItem, {required bool isEdit}) {
    debugPrint('🔵 _showFoodBottomSheet called - isEdit: $isEdit, food: ${foodItem.foodName}');

    final controller = Get.find<RestaurantDetailViewController>();
    controller.selectFoodItem(foodItem, isEdit: isEdit);

    debugPrint('🔵 About to show bottom sheet...');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) {
        debugPrint('🔵 Bottom sheet builder called');
        return FoodDetailsBottomSheet();
      },
    ).then((_) {
      debugPrint('🔵 Bottom sheet closed, resetting state');
      controller.resetBottomSheetState();
    });
  }
}
