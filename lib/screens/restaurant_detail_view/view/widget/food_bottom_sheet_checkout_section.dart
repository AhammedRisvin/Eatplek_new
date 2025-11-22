import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/util/app_color.dart';
import '../../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import 'quantity_control_widget.dart';

class FoodBottomSheetCheckoutSection extends StatelessWidget {
  const FoodBottomSheetCheckoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'total_price',
      builder: (controller) {
        final totalPrice = controller.getTotalBottomSheetPrice();
        final basePrice = controller.getBasePrice();
        final hasCustomizations = controller.hasCustomizations;
        final isEditMode = controller.isEditMode;
        final buttonText = controller.getBottomSheetButtonText();

        // Get the quantity for Scenario A
        final scenarioAQuantity = controller.getBottomSheetItemQuantity();

        // Determine if button should be enabled
        bool isButtonEnabled = true;
        if (hasCustomizations) {
          isButtonEnabled = controller.getTotalCustomizationQuantity() > 0;
        } else {
          // For Scenario A, button is enabled if quantity > 0
          isButtonEnabled = scenarioAQuantity > 0;
        }

        debugPrint(
          '🟢 Checkout section rebuild - price: $totalPrice, enabled: $isButtonEnabled, mode: ${isEditMode ? 'EDIT' : 'ADD'}',
        );

        return Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: AppColor.white,
            border: BorderDirectional(top: BorderSide(color: AppColor.black.withOpacity(0.1), width: 1)),
            boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.08), blurRadius: 14, offset: Offset(0, -2))],
          ),
          padding: EdgeInsets.only(top: 11, left: 16, right: 16, bottom: 16),
          child: Row(
            children: [
              // SCENARIO A ONLY: Quantity control on left
              if (!hasCustomizations)
                GetBuilder<RestaurantDetailViewController>(
                  id: 'total_price',
                  builder: (controller) {
                    final quantity = controller.getBottomSheetItemQuantity();
                    return QuantityControlWidget(
                      quantity: quantity,
                      onIncrease: () {
                        debugPrint('🟢 Increase quantity in bottom sheet - old: $quantity');
                        controller.increaseBottomSheetItemQuantity();
                      },
                      onDecrease: () {
                        debugPrint('🟢 Decrease quantity in bottom sheet - old: $quantity');
                        controller.decreaseBottomSheetItemQuantity();
                      },
                      showRemoveButton: true,
                      buttonSize: 28,
                      iconSize: 14,
                    );
                  },
                )
              else
                // SCENARIO B & C: Show total items on left
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    text(
                      text: 'Total Amount',
                      size: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.black.withOpacity(0.6),
                    ),
                    text(
                      text: '₹${totalPrice.toStringAsFixed(0)}',
                      size: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                  ],
                ),

              Spacer(),

              // Add/Edit item button with price inside
              GestureDetector(
                onTap:
                    isButtonEnabled
                        ? () {
                          debugPrint('🟢 $buttonText button tapped');
                          controller.addItemToCart();
                        }
                        : null,
                child: Container(
                  height: 50,
                  constraints: BoxConstraints(maxWidth: 160),
                  decoration: BoxDecoration(
                    color: isButtonEnabled ? AppColor.appPrimary : AppColor.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        text(
                          text: buttonText,
                          size: 12,
                          fontWeight: FontWeight.w600,
                          color: isButtonEnabled ? AppColor.white : AppColor.black.withOpacity(0.5),
                        ),
                        2.h,
                        text(
                          text: '₹${totalPrice.toStringAsFixed(0)}',
                          size: 16,
                          fontWeight: FontWeight.w700,
                          color: isButtonEnabled ? AppColor.white : AppColor.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
