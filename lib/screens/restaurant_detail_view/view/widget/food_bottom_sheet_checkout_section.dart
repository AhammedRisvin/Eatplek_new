import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import 'quantity_control_widget.dart';

class FoodBottomSheetCheckoutSection extends StatelessWidget {
  const FoodBottomSheetCheckoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<RestaurantDetailViewController>(
      id: 'total_price',
      builder: (controller) {
        final totalPrice = controller.getTotalBottomSheetPrice();
        final hasCustomizations = controller.hasCustomizations;
        final isEditMode = controller.isEditMode;
        final buttonText = controller.getBottomSheetButtonText();

        final scenarioAQuantity = controller.getBottomSheetItemQuantity();
        final totalCustomizationQty = controller.getTotalCustomizationQuantity();

        bool isButtonEnabled = true;

        if (hasCustomizations) {
          if (isEditMode) {
            isButtonEnabled = true;
          } else {
            isButtonEnabled = totalCustomizationQty > 0;
          }
        } else {
          if (isEditMode) {
            isButtonEnabled = true;
          } else {
            isButtonEnabled = scenarioAQuantity >= 1;
          }
        }

        debugPrint(
          '🟢 Checkout section rebuild - price: $totalPrice, enabled: $isButtonEnabled, mode: ${isEditMode ? "EDIT" : "ADD"}, customizations: $totalCustomizationQty, qty: $scenarioAQuantity',
        );

        return Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: AppColor.white,
            border: BorderDirectional(top: BorderSide(color: AppColor.black.withOpacity(0.1), width: 1)),
            boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.08), blurRadius: 14, offset: Offset(0, -2))],
          ),
          padding: EdgeInsets.only(
            top: responsive.spacing11,
            left: responsive.spacing16,
            right: responsive.spacing16,
            bottom: responsive.spacing16,
          ),
          child: Row(
            children: [
              // Quantity control or total amount
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
                      buttonSize: responsive.spacing28,
                      iconSize: responsive.fontSize14,
                    );
                  },
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    text(
                      text: 'Total Amount',
                      size: responsive.fontSize14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.black.withOpacity(0.6),
                    ),
                    text(
                      text: '₹${totalPrice.toStringAsFixed(0)}',
                      size: responsive.fontSize22,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                  ],
                ),

              Spacer(),

              // Add/Edit button
              GestureDetector(
                onTap:
                    isButtonEnabled
                        ? () {
                          debugPrint('🟢 $buttonText button tapped');
                          controller.addOrUpdateItemToCart();
                        }
                        : null,
                child: Container(
                  height: responsive.spacing50,
                  constraints: BoxConstraints(maxWidth: responsive.spacing160),
                  decoration: BoxDecoration(
                    color: isButtonEnabled ? AppColor.appPrimary : AppColor.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        text(
                          text: buttonText,
                          size: responsive.fontSize12,
                          fontWeight: FontWeight.w600,
                          color: isButtonEnabled ? AppColor.white : AppColor.black.withOpacity(0.5),
                        ),
                        SizedBox(height: responsive.spacing2),
                        text(
                          text: '₹${totalPrice.toStringAsFixed(0)}',
                          size: responsive.fontSize16,
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
