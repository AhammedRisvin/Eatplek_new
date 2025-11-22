import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import '../../model/restaurent_details_model.dart';
import 'food_bottom_sheet_add_ones_section.dart';
import 'food_bottom_sheet_checkout_section.dart';
import 'food_bottom_sheet_customisation.dart';

class FoodDetailsBottomSheet extends StatefulWidget {
  const FoodDetailsBottomSheet({super.key});

  @override
  State<FoodDetailsBottomSheet> createState() => _FoodDetailsBottomSheetState();
}

class _FoodDetailsBottomSheetState extends State<FoodDetailsBottomSheet> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 FoodDetailsBottomSheet initState called');
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟢 FoodDetailsBottomSheet build called');

    return GetBuilder<RestaurantDetailViewController>(
      id: 'bottom_sheet_content',
      builder: (controller) {
        final foodItem = controller.selectedFoodItem;
        debugPrint('🟢 Selected food: ${foodItem?.foodName}');

        if (foodItem == null) {
          debugPrint('🔴 ERROR: selectedFoodItem is null!');
          return SizedBox();
        }

        final hasCustomizations = controller.hasCustomizations;
        final hasAddOns = controller.hasAddOns;

        debugPrint('🟢 hasCustomizations: $hasCustomizations, hasAddOns: $hasAddOns');

        return Stack(
          children: [
            // Dismissible background
            GestureDetector(
              onTap: () {
                debugPrint('🟢 Tapped outside bottom sheet, closing');
                controller.resetBottomSheetState();
                Get.back();
              },
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            // Bottom sheet - Positioned at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: 0,
              child: DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                expand: false,
                builder: (context, scrollController) {
                  debugPrint('🟢 DraggableScrollableSheet builder called');

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColor.scaffoldColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar + Close button
                        _buildHandleBar(controller),

                        // Scrollable content
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFoodDetailsSection(controller, foodItem),
                                if (!hasCustomizations && !hasAddOns) ...[
                                  40.h,
                                  Center(
                                    child: text(
                                      text: 'No customizations or add-ons available',
                                      size: 16,
                                      color: AppColor.black.withOpacity(0.5),
                                    ),
                                  ),
                                  40.h,
                                ] else if (!hasCustomizations && hasAddOns) ...[
                                  20.h,
                                  FoodBottomSheetAddOnsSection(foodItem: foodItem),
                                  100.h,
                                ] else if (hasCustomizations) ...[
                                  20.h,
                                  FoodBottomSheetCustomizationSection(foodItem: foodItem),
                                  20.h,
                                  if (hasAddOns) ...[FoodBottomSheetAddOnsSection(foodItem: foodItem)],
                                  100.h,
                                ],
                              ],
                            ),
                          ),
                        ),
                        FoodBottomSheetCheckoutSection(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHandleBar(RestaurantDetailViewController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Handle bar
          Expanded(
            child: Center(
              child: Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: Color(0XFFD9D9D9)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodDetailsSection(RestaurantDetailViewController controller, Food foodItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image(
              url: foodItem.foodImage ?? '',
              height: 200,
              width: Get.width - 40,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        16.h,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(text: foodItem.foodName ?? '', size: 20, fontWeight: FontWeight.w600, color: AppColor.black),
              8.h,
              text(
                text: 'Select options below',
                size: 12,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.6),
              ),
            ],
          ),
        ),
        16.h,
        Divider(color: AppColor.black.withOpacity(0.1), thickness: 1),
      ],
    );
  }
}
