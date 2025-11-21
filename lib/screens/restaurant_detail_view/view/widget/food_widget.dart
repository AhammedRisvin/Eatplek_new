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
    return GestureDetector(
      onTap: () {
        Get.find<RestaurantDetailViewController>().navigateToFoodDetail(foodItem);
      },
      child: Container(
        width: context.wp(100),
        height: 200,
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
              child: image(
                url: foodItem.foodImage ?? '',
                height: 120,
                width: context.wp(100),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            10.h,
            Row(
              children: [
                Expanded(
                  child: text(
                    text: foodItem.foodName ?? '',
                    size: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColor.black,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
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
                Spacer(),
                QuantityControlWidget(
                  quantity: 0,
                  onIncrease: () => _showFoodBottomSheet(context, foodItem),
                  onDecrease: () {},
                  showRemoveButton: false,
                  buttonSize: 28,
                  iconSize: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFoodBottomSheet(BuildContext context, Food foodItem) {
    final controller = Get.find<RestaurantDetailViewController>();
    controller.selectFoodItem(foodItem);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.scaffoldColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (context) => FoodDetailsBottomSheet(),
    );
  }
}
