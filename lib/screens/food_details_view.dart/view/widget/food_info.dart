import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/assets.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../restaurant_detail_view/controller/restaurant_detail_view_controller.dart';
import '../../../restaurant_detail_view/view/widget/quantity_control_widget.dart';

class FoodInfoSection extends StatelessWidget {
  final String foodName;
  final String foodId;
  final bool hasCustomizations;
  final RestaurantDetailViewController controller;

  const FoodInfoSection({
    super.key,
    required this.foodName,
    required this.foodId,
    required this.hasCustomizations,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(text: foodName, size: 20, fontWeight: FontWeight.w600, maxLines: 2, overFlow: TextOverflow.ellipsis),
              10.h,
              Row(
                children: [
                  SvgPicture.string(locationUnFilled),
                  8.w,
                  text(text: '12 KM', color: AppColor.black.withOpacity(0.6), size: 16, fontWeight: FontWeight.w400),
                  10.w,
                  CircleAvatar(radius: 3, backgroundColor: AppColor.black.withOpacity(0.4)),
                  10.w,
                  SvgPicture.string(deliveryBike),
                  8.w,
                  text(
                    text: '25–35 mins',
                    color: AppColor.black.withOpacity(0.6),
                    size: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Show quantity control only if no customizations
        if (!hasCustomizations)
          GetBuilder<RestaurantDetailViewController>(
            id: 'food_quantity_widget',
            builder: (controller) {
              final quantity = controller.getCustomizationCount(foodId);
              return QuantityControlWidget(
                quantity: quantity,
                onIncrease: () => controller.toggleCustomization(''),
                onDecrease: controller.decreaseCustomization,
                showRemoveButton: quantity > 0,
                buttonSize: quantity > 0 ? 40 : 60,
                iconSize: 18,
                addButtonText: quantity == 0 ? 'ADD' : null,
              );
            },
          ),
      ],
    );
  }
}
