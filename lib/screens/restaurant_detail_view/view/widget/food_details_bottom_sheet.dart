import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
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
    final responsive = ResponsiveHelper();

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
                onTap: () {
                  debugPrint('🔵 Tapped outside bottom sheet - dismissing without saving');
                  controller.resetBottomSheetState();
                  Navigator.pop(Get.context!);
                },
                child: Container(
                  color: Colors.transparent,
                  child: GestureDetector(
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
                            borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.largeBorderRadius)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHandleBar(controller, responsive),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildFoodDetailsSection(controller, foodItem, responsive),
                                      if (isScenario1) ...[
                                        SizedBox(height: responsive.spacing20),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
                                          child: text(
                                            text: 'Adjust quantity from the food card',
                                            size: responsive.fontSize14,
                                            color: AppColor.black.withOpacity(0.6),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: responsive.spacing20),
                                      ] else if (!hasCustomizations && hasAddOns) ...[
                                        SizedBox(height: responsive.spacing20),
                                        FoodBottomSheetAddOnsSection(foodItem: foodItem),
                                        SizedBox(height: responsive.spacing30),
                                      ] else if (hasCustomizations) ...[
                                        SizedBox(height: responsive.spacing20),
                                        FoodBottomSheetCustomizationSection(foodItem: foodItem),
                                        SizedBox(height: responsive.spacing20),
                                        if (hasAddOns) ...[FoodBottomSheetAddOnsSection(foodItem: foodItem)],
                                        SizedBox(height: responsive.spacing30),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
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

  Widget _buildHandleBar(RestaurantDetailViewController controller, ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing20, vertical: responsive.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: responsive.spacing120,
                height: responsive.spacing4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                  color: Color(0XFFD9D9D9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodDetailsSection(
    RestaurantDetailViewController controller,
    Food foodItem,
    ResponsiveHelper responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            child: image(
              url: foodItem.foodImage ?? '',
              height: responsive.spacing200,
              width: Get.width - responsive.spacing40,
              borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            ),
          ),
        ),
        SizedBox(height: responsive.spacing16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              text(
                text: foodItem.foodName ?? '',
                size: responsive.fontSize20,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
              SizedBox(height: responsive.spacing8),
              text(
                text: 'Select options below',
                size: responsive.fontSize12,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.6),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.spacing16),
        Divider(color: AppColor.black.withOpacity(0.1), thickness: 1),
      ],
    );
  }
}
