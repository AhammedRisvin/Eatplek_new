import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/util/app_color.dart';
import '../../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import '../../model/restaurent_details_model.dart';
import 'quantity_control_widget.dart';

class FoodBottomSheetFoodSection extends StatelessWidget {
  final Food foodItem;
  final bool showQuantityControl;

  const FoodBottomSheetFoodSection({super.key, required this.foodItem, this.showQuantityControl = true});

  @override
  Widget build(BuildContext context) {
    if (showQuantityControl) {
      return _buildFoodItemWithQuantity();
    } else {
      return _buildFoodItemWithoutQuantity();
    }
  }

  // Scenario 1 & 2: Food item with quantity control
  Widget _buildFoodItemWithQuantity() {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColor.white),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 17),
      child: Row(
        children: [
          image(url: foodItem.foodImage ?? '', height: 40, width: 40, borderRadius: BorderRadius.circular(4)),
          20.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: foodItem.foodName ?? '',
                  size: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black,
                  maxLines: 1,
                  overFlow: TextOverflow.ellipsis,
                ),
                4.h,
                text(
                  text: '₹ ${(foodItem.discountPrice ?? foodItem.foodPrice ?? 0).toInt()}',
                  size: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          GetBuilder<RestaurantDetailViewController>(
            id: 'food_quantity_widget',
            builder: (controller) {
              return QuantityControlWidget(
                quantity: controller.getCustomizationCount(foodItem.foodId ?? ''),
                onIncrease: () => controller.toggleCustomization(''),
                onDecrease: controller.decreaseCustomization,
                showRemoveButton: true,
                buttonSize: 32,
                iconSize: 14,
              );
            },
          ),
        ],
      ),
    );
  }

  // Scenario 3: Food item without quantity control (moved to customization tiles)
  Widget _buildFoodItemWithoutQuantity() {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 17),
      child: Row(
        children: [
          image(url: foodItem.foodImage ?? '', height: 40, width: 40, borderRadius: BorderRadius.circular(4)),
          20.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: foodItem.foodName ?? '',
                  size: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black,
                  maxLines: 1,
                  overFlow: TextOverflow.ellipsis,
                ),
                4.h,
                text(
                  text: '₹ ${(foodItem.discountPrice ?? foodItem.foodPrice ?? 0).toInt()}',
                  size: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
