import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import 'food_bottom_sheet_add_ones_section.dart';
import 'food_bottom_sheet_checkout_section.dart';
import 'food_bottom_sheet_customisation.dart';
import 'food_bottom_sheet_food_section.dart';
import 'food_bottom_sheet_header.dart';

class FoodDetailsBottomSheet extends StatelessWidget {
  const FoodDetailsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'bottom_sheet_content',
      builder: (controller) {
        final foodItem = controller.selectedFoodItem;
        if (foodItem == null) return SizedBox();

        final hasCustomizations = controller.hasCustomizations;
        final hasAddOns = controller.hasAddOns;

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColor.scaffoldColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  FoodBottomSheetHeader(foodItem: foodItem),

                  // Content Based on Customizations and Add-ons
                  if (!hasCustomizations && !hasAddOns) ...[
                    // Scenario 1: No customizations and no add-ons
                    FoodBottomSheetFoodSection(foodItem: foodItem, showQuantityControl: true),
                    Expanded(
                      child: Center(
                        child: text(
                          text: 'No customizations or add-ons available',
                          size: 16,
                          color: AppColor.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ] else if (!hasCustomizations && hasAddOns) ...[
                    // Scenario 2: No customizations but has add-ons
                    FoodBottomSheetFoodSection(foodItem: foodItem, showQuantityControl: true),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [FoodBottomSheetAddOnsSection(foodItem: foodItem), 100.h],
                        ),
                      ),
                    ),
                  ] else if (hasCustomizations) ...[
                    // Scenario 3: Has customizations (with or without add-ons)
                    FoodBottomSheetFoodSection(foodItem: foodItem, showQuantityControl: false),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FoodBottomSheetCustomizationSection(foodItem: foodItem),
                            20.h,
                            if (hasAddOns) ...[FoodBottomSheetAddOnsSection(foodItem: foodItem)],
                            100.h,
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Checkout Section
                  FoodBottomSheetCheckoutSection(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
