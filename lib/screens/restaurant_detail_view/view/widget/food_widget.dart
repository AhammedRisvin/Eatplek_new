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
    final controller = Get.find<RestaurantDetailViewController>();
    final hasCustomizations = foodItem.customizations != null && foodItem.customizations!.isNotEmpty;
    final hasAddOns = foodItem.addOns != null && foodItem.addOns!.isNotEmpty;

    // ✅ Capitalize first letter of food name
    final capitalizedFoodName = _capitalizeFirstLetter(foodItem.foodName ?? '');

    return Container(
      width: context.wp(100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Food Image with Location & Share buttons overlay
          _buildImageWithButtons(context, controller, hasCustomizations, hasAddOns),

          // Food Details Section
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Name
                text(
                  text: capitalizedFoodName,
                  size: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black,
                  maxLines: 1,
                  overFlow: TextOverflow.ellipsis,
                ),
                8.h,

                // Price Section
                _buildPriceSection(),
                10.h,

                // Action Button (Add/Edit or QuantityControl)
                _buildActionButton(context, controller, hasCustomizations, hasAddOns),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Image with Location & Share buttons on top-right corner
  Widget _buildImageWithButtons(
    BuildContext context,
    RestaurantDetailViewController controller,
    bool hasCustomizations,
    bool hasAddOns,
  ) {
    return GestureDetector(
      onTap: () {
        debugPrint('🍔 Food image tapped - Opening bottom sheet');
        _showFoodBottomSheet(context, controller, hasCustomizations, hasAddOns, isEdit: false);
      },
      child: Stack(
        children: [
          // Food Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: image(
              url: foodItem.foodImage ?? '',
              height: 140,
              width: context.wp(100),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),

          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [_buildOverlayButton(onTap: () => _shareFood(), icon: Icons.share_outlined, label: 'Share')],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Overlay button - appears on image
  Widget _buildOverlayButton({required VoidCallback onTap, required IconData icon, required String label}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColor.white.withOpacity(0.95),
          boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.12), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColor.appPrimary),
            4.w,
            text(text: label, size: 10, fontWeight: FontWeight.w600, color: AppColor.appPrimary),
          ],
        ),
      ),
    );
  }

  // ✅ Price Section with discount display
  Widget _buildPriceSection() {
    final discountPrice = foodItem.discountPrice ?? foodItem.foodPrice ?? 0;
    final actualPrice = foodItem.actualPrice ?? foodItem.foodPrice ?? 0;
    final hasDiscount = actualPrice > discountPrice;

    return Row(
      children: [
        // Current Price
        text(text: '₹${discountPrice.toInt()}', size: 14, fontWeight: FontWeight.w700, color: AppColor.appPrimary),

        // Original Price (if discount exists)
        if (hasDiscount) ...[
          8.w,
          text(
            text: '₹${actualPrice.toInt()}',
            size: 11,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.4),
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColor.black.withOpacity(0.4),
          ),
          8.w,
          // Discount percentage
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Color(0xFFFF6B6B).withOpacity(0.15),
            ),
            child: text(
              text: '${_calculateDiscount(actualPrice, discountPrice).toInt()}% off',
              size: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ],
      ],
    );
  }

  // ✅ Action Button - Show QuantityControlWidget for Scenario 1, Add/Edit button for others
  Widget _buildActionButton(
    BuildContext context,
    RestaurantDetailViewController controller,
    bool hasCustomizations,
    bool hasAddOns,
  ) {
    final foodId = foodItem.foodId ?? '';
    if (foodId.isEmpty) return SizedBox();

    final isScenario1 = !hasCustomizations && !hasAddOns;

    // ✅ SCENARIO 1: Show QuantityControlWidget - Full width and centered
    if (isScenario1) {
      return GetBuilder<RestaurantDetailViewController>(
        id: 'food_grid',
        builder: (controller) {
          final quantity = controller.cartFoodQuantity[foodId] ?? 0;

          return Container(
            width: context.wp(100),
            height: 36,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: AppColor.white),
            child: Center(
              child: QuantityControlWidget(
                quantity: quantity,
                onIncrease: () {
                  debugPrint('🍕 Increase quantity: ${foodItem.foodName}');
                  controller.increaseScenario1Quantity(foodId);
                },
                onDecrease: () {
                  debugPrint('🍕 Decrease quantity: ${foodItem.foodName}');
                  controller.decreaseScenario1Quantity(foodId);
                },
                showRemoveButton: true,
                buttonSize: 28,
                iconSize: 14,
                addButtonText: 'Add',
              ),
            ),
          );
        },
      );
    }

    // ✅ SCENARIOS 2-4: Show Add/Edit button with bottom sheet
    return GetBuilder<RestaurantDetailViewController>(
      id: 'food_grid',
      builder: (controller) {
        final isInCart = controller.isFoodInCart(foodId);

        final isEditMode = isInCart;
        final buttonText = isEditMode ? 'Edit' : 'Add';
        final bgColor = isEditMode ? AppColor.appPrimary.withOpacity(0.15) : AppColor.appPrimary;
        final textColor = isEditMode ? AppColor.appPrimary : AppColor.white;

        return GestureDetector(
          onTap: () {
            debugPrint('🔵 Add/Edit button tapped: ${foodItem.foodName}');
            _showFoodBottomSheet(context, controller, hasCustomizations, hasAddOns, isEdit: isEditMode);
          },
          child: Container(
            width: context.wp(100),
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: bgColor,
              border: isEditMode ? Border.all(color: AppColor.appPrimary, width: 1.5) : null,
            ),
            child: Center(child: text(text: buttonText, size: 13, fontWeight: FontWeight.w600, color: textColor)),
          ),
        );
      },
    );
  }

  // ✅ Show appropriate bottom sheet based on scenario
  void _showFoodBottomSheet(
    BuildContext context,
    RestaurantDetailViewController controller,
    bool hasCustomizations,
    bool hasAddOns, {
    required bool isEdit,
  }) {
    debugPrint('🔵 _showFoodBottomSheet called - isEdit: $isEdit, food: ${foodItem.foodName}');

    controller.selectFoodItem(foodItem, isEdit: isEdit);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        debugPrint('🔵 Bottom sheet builder called');
        return FoodDetailsBottomSheet();
      },
    ).then((_) {
      debugPrint('🔵 Bottom sheet closed');
      controller.resetBottomSheetState();
    });
  }

  // ✅ Share food using shareLink
  void _shareFood() {
    debugPrint('📤 Sharing food item');
    if (foodItem.shareLink != null && foodItem.shareLink!.isNotEmpty) {
      debugPrint('Share Link: ${foodItem.shareLink}');
      Get.snackbar(
        'Share',
        'Sharing: ${foodItem.foodName}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } else {
      Get.snackbar('Share', 'Share link not available');
    }
  }

  // ✅ Capitalize first letter of food name
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // ✅ Calculate discount percentage
  double _calculateDiscount(double actual, double discounted) {
    if (actual == 0) return 0;
    return ((actual - discounted) / actual) * 100;
  }
}
