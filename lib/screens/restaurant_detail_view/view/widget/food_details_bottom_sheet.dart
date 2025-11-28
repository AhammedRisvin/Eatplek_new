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
        final isScenario1 = !hasCustomizations && !hasAddOns;

        debugPrint('🟢 isScenario1: $isScenario1, hasCustomizations: $hasCustomizations, hasAddOns: $hasAddOns');

        return Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: 0,
              child: GestureDetector(
                // ✅ FIXED: Use Navigator.pop instead of Get.back to avoid snackbar controller error
                onTap: () {
                  debugPrint('🔵 Tapped outside bottom sheet - dismissing without saving');
                  controller.resetBottomSheetState();
                  Navigator.pop(Get.context!);
                },
                child: Container(
                  color: Colors.transparent,
                  child: GestureDetector(
                    // ✅ Prevent propagation when tapping inside bottom sheet
                    onTap: () {},
                    child: DraggableScrollableSheet(
                      initialChildSize: isScenario1 ? 0.5 : 0.7,
                      minChildSize: 0.3,
                      maxChildSize: isScenario1 ? 0.75 : 0.95,
                      expand: false,
                      builder: (context, scrollController) {
                        debugPrint('🟢 DraggableScrollableSheet builder called');

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColor.scaffoldColor,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                          // ✅ KEY FIX: Use Column with proper layout strategy
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Handle bar
                              _buildHandleBar(controller),

                              // ✅ FIXED: Scrollable content with only content height
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildFoodDetailsSection(controller, foodItem),

                                      // ✅ SCENARIO 1: View-only message (NO extra space)
                                      if (isScenario1) ...[
                                        20.h,
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          child: text(
                                            text: 'Adjust quantity from the food card',
                                            size: 14,
                                            color: AppColor.black.withOpacity(0.6),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        20.h,
                                      ]
                                      // ✅ SCENARIOS 2-4: Show sections with content
                                      else if (!hasCustomizations && hasAddOns) ...[
                                        20.h,
                                        FoodBottomSheetAddOnsSection(foodItem: foodItem),
                                        30.h, // ✅ REDUCED: Bottom padding for checkout
                                      ] else if (hasCustomizations) ...[
                                        20.h,
                                        FoodBottomSheetCustomizationSection(foodItem: foodItem),
                                        20.h,
                                        if (hasAddOns) ...[FoodBottomSheetAddOnsSection(foodItem: foodItem)],
                                        30.h, // ✅ REDUCED: Bottom padding for checkout
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              // ✅ CHECKOUT SECTION: Only for Scenarios 2-4
                              if (!isScenario1) FoodBottomSheetCheckoutSection(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
      mainAxisSize: MainAxisSize.min,
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
            mainAxisSize: MainAxisSize.min,
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
