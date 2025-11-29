import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../restaurant_detail_view/view/widget/quantity_control_widget.dart';
import '../../controller/cart_controller.dart';
import '../../model/cart_api_model.dart';
import 'dotted_line_painter.dart';

class CartFoodListWidget extends StatelessWidget {
  const CartFoodListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      id: 'cart_items',
      builder: (controller) {
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) => _buildCartItem(context, controller, controller.cartItems[index]),
          separatorBuilder: (context, index) => 0.h,
          itemCount: controller.cartItems.length,
        );
      },
    );
  }

  Widget _buildCartItem(BuildContext context, CartController controller, CartItem cartItem) {
    final scenario = _detectScenario(cartItem);

    return Container(
      width: context.wp(100),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMainContent(cartItem, controller, scenario),
          if (scenario == 2) ...[20.h, _buildDivider(), 16.h, _buildAddOnsSection(cartItem, controller)],
          if (scenario == 3) ...[20.h, _buildDivider(), 16.h, _buildCustomizationsSection(cartItem, controller)],
          if (scenario == 4) ...[
            20.h,
            _buildDivider(),
            16.h,
            _buildCustomizationsSection(cartItem, controller),
            if (cartItem.addOns?.isNotEmpty ?? false) ...[
              20.h,
              _buildDivider(),
              16.h,
              _buildAddOnsSection(cartItem, controller),
            ],
          ],
        ],
      ),
    );
  }

  /// SCENARIO DETECTION
  int _detectScenario(CartItem item) {
    final hasCustomizations = item.customizations != null && item.customizations!.isNotEmpty;
    final hasAddOns = item.addOns != null && item.addOns!.isNotEmpty;

    if (!hasCustomizations && !hasAddOns) {
      return 1; // Food only
    } else if (!hasCustomizations && hasAddOns) {
      return 2; // Food + Add-ons
    } else if (hasCustomizations && !hasAddOns) {
      return 3; // Customization only
    } else {
      return 4; // Customization + Add-ons
    }
  }

  /// ✅ SCENARIO 1 & 2: Main content with food image, name, price
  /// - Scenario 1: QuantityControlWidget on right side
  /// - Scenario 2: QuantityControlWidget on right side (for food quantity)
  /// - Scenario 3 & 4: NO QuantityControlWidget on right side
  Widget _buildMainContent(CartItem cartItem, CartController controller, int scenario) {
    return Row(
      children: [
        image(url: cartItem.foodImage ?? '', width: 80, height: 80, borderRadius: BorderRadius.circular(10)),
        20.w,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemName(cartItem.foodName ?? ''),
              if (cartItem.foodType != null) _buildItemCategory(cartItem.foodType ?? ''),
              _buildPriceAndQuantity(cartItem, controller, scenario),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemName(String name) {
    return text(
      text: name,
      fontWeight: FontWeight.w600,
      size: 16,
      maxLines: 2,
      textAlign: TextAlign.start,
      overFlow: TextOverflow.ellipsis,
    );
  }

  Widget _buildItemCategory(String category) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: text(
        text: category,
        fontWeight: FontWeight.w400,
        size: 14,
        maxLines: 2,
        color: AppColor.black.withOpacity(0.6),
        textAlign: TextAlign.start,
        overFlow: TextOverflow.ellipsis,
      ),
    );
  }

  /// ✅ Price and Quantity Row
  /// - Scenario 1 & 2: Show QuantityControlWidget on right
  /// - Scenario 3 & 4: Show price only, no QuantityControlWidget
  Widget _buildPriceAndQuantity(CartItem cartItem, CartController controller, int scenario) {
    if (scenario == 3 || scenario == 4) {
      // Scenario 3 & 4: Only show price (no quantity control on right side)
      return Padding(
        padding: EdgeInsets.only(top: 8),
        child: text(
          // ✅ FIXED: Use itemTotal directly from API
          text: 'Rs.${cartItem.basePrice?.toInt() ?? 0}',
          fontWeight: FontWeight.w500,
          size: 18,
          maxLines: 2,
          textAlign: TextAlign.start,
          overFlow: TextOverflow.ellipsis,
        ),
      );
    }

    // Scenario 1 & 2: Show price and quantity control
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: text(
              // ✅ FIXED: Use itemTotal directly from API (already includes everything)
              text: 'Rs.${cartItem.basePrice?.toInt() ?? 0}',
              fontWeight: FontWeight.w500,
              size: 18,
              maxLines: 2,
              textAlign: TextAlign.start,
              overFlow: TextOverflow.ellipsis,
            ),
          ),
          GetBuilder<CartController>(
            id: 'cart_items',
            builder: (ctrl) {
              return QuantityControlWidget(
                quantity: cartItem.quantity ?? 1,
                onIncrease: () => controller.updateItemQuantity(cartItem.foodId ?? '', (cartItem.quantity ?? 1) + 1),
                onDecrease: () => controller.updateItemQuantity(cartItem.foodId ?? '', (cartItem.quantity ?? 1) - 1),
                showRemoveButton: true,
                buttonSize: 28,
                iconSize: 14,
                margin: const EdgeInsets.only(right: 0),
                isCompactMode: true,
              );
            },
          ),
        ],
      ),
    );
  }

  /// ✅ SCENARIO 2 & 4: Add-ons section
  /// Each add-on has its own QuantityControlWidget
  Widget _buildAddOnsSection(CartItem cartItem, CartController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            text(text: 'Add Ons', fontWeight: FontWeight.w600, size: 16),
            const Spacer(),
            // Will implement "Add more" later
          ],
        ),
        16.h,
        _buildAddOnsList(cartItem, controller),
      ],
    );
  }

  Widget _buildAddOnsList(CartItem cartItem, CartController controller) {
    final addOns = cartItem.addOns ?? [];
    if (addOns.isEmpty) return SizedBox.shrink();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => _buildAddOnItem(cartItem, addOns[index], controller),
      separatorBuilder: (context, index) => 10.h,
      itemCount: addOns.length,
    );
  }

  Widget _buildAddOnItem(CartItem cartItem, AddOn addOn, CartController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColor.black.withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: addOn.name ?? '',
                  fontWeight: FontWeight.w500,
                  size: 14,
                  maxLines: 1,
                  overFlow: TextOverflow.ellipsis,
                ),
                4.h,
                text(
                  text: 'Rs.${addOn.price ?? 0}',
                  fontWeight: FontWeight.w400,
                  size: 12,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          GetBuilder<CartController>(
            id: 'cart_items',
            builder: (ctrl) {
              return QuantityControlWidget(
                quantity: addOn.quantity ?? 0,
                onIncrease:
                    () => controller.updateItemQuantity(
                      cartItem.foodId ?? '',
                      (addOn.quantity ?? 0) + 1,
                      addOnId: addOn.addOnId,
                    ),
                onDecrease:
                    () => controller.updateItemQuantity(
                      cartItem.foodId ?? '',
                      (addOn.quantity ?? 0) - 1,
                      addOnId: addOn.addOnId,
                    ),
                showRemoveButton: true,
                buttonSize: 24,
                iconSize: 12,
                margin: EdgeInsets.zero,
                isCompactMode: true,
              );
            },
          ),
        ],
      ),
    );
  }

  /// ✅ SCENARIO 3 & 4: Customizations section
  /// Each customization has its own QuantityControlWidget (NO food quantity control)
  Widget _buildCustomizationsSection(CartItem cartItem, CartController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            text(text: 'Customizations', fontWeight: FontWeight.w600, size: 16),
            const Spacer(),
            // Will implement "Add more" later
          ],
        ),
        16.h,
        _buildCustomizationsList(cartItem, controller),
      ],
    );
  }

  Widget _buildCustomizationsList(CartItem cartItem, CartController controller) {
    final customizations = cartItem.customizations ?? [];
    if (customizations.isEmpty) return SizedBox.shrink();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => _buildCustomizationItem(cartItem, customizations[index], controller),
      separatorBuilder: (context, index) => 10.h,
      itemCount: customizations.length,
    );
  }

  Widget _buildCustomizationItem(CartItem cartItem, AddOn customization, CartController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColor.black.withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: customization.name ?? '',
                  fontWeight: FontWeight.w500,
                  size: 14,
                  maxLines: 1,
                  overFlow: TextOverflow.ellipsis,
                ),
                4.h,
                text(
                  text: 'Rs.${customization.price ?? 0}',
                  fontWeight: FontWeight.w400,
                  size: 12,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          GetBuilder<CartController>(
            id: 'cart_items',
            builder: (ctrl) {
              return QuantityControlWidget(
                quantity: customization.quantity ?? 0,
                onIncrease:
                    () => controller.updateItemQuantity(
                      cartItem.foodId ?? '',
                      (customization.quantity ?? 0) + 1,
                      customizationId: customization.customizationId,
                    ),
                onDecrease:
                    () => controller.updateItemQuantity(
                      cartItem.foodId ?? '',
                      (customization.quantity ?? 0) - 1,
                      customizationId: customization.customizationId,
                    ),
                showRemoveButton: true,
                buttonSize: 24,
                iconSize: 12,
                margin: EdgeInsets.zero,
                isCompactMode: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: DottedLinePainter(color: AppColor.black.withOpacity(0.1))),
    );
  }
}
