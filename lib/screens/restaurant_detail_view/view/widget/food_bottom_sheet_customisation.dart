import 'dart:developer';

import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/util/app_color.dart';
import '../../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import '../../model/restaurent_details_model.dart';
import 'quantity_control_widget.dart';

class FoodBottomSheetCustomizationSection extends StatelessWidget {
  final Food foodItem;

  const FoodBottomSheetCustomizationSection({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    if (foodItem.customizations == null || foodItem.customizations!.isEmpty) {
      return SizedBox();
    }

    return GetBuilder<RestaurantDetailViewController>(
      id: 'customization_widget',
      builder: (controller) {
        final customizations = foodItem.customizations!;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(text: 'Customize Your Food', size: 18, fontWeight: FontWeight.w600),
              3.h,
              text(
                text: 'Choose your preferred size or variant.',
                size: 12,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.6),
              ),
              20.h,
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final customization = customizations[index];
                  return _buildCustomizationTile(controller, customization);
                },
                separatorBuilder: (context, index) => 16.h,
                itemCount: customizations.length,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomizationTile(RestaurantDetailViewController controller, Customization customization) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(text: customization.name ?? '', size: 14, fontWeight: FontWeight.w600, color: AppColor.black),
                4.h,
                text(
                  text: '₹ ${customization.price?.toInt() ?? 0}',
                  size: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          GetBuilder<RestaurantDetailViewController>(
            id: 'customization_widget',
            builder: (controller) {
              final quantity = controller.getCustomizationCount(customization.customizationId ?? '');
              return QuantityControlWidget(
                quantity: quantity,
                onIncrease: () {
                  log('price ${customization.price}');
                  controller.toggleCustomization(customization.customizationId ?? '');
                },
                onDecrease: () => controller.decreaseCustomization(customization.customizationId ?? ''),
                showRemoveButton: quantity > 0,
                buttonSize: 28,
                iconSize: 12,
              );
            },
          ),
        ],
      ),
    );
  }
}
