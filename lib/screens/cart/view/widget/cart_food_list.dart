import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/price_formatter.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../restaurant_detail_view/view/widget/quantity_control_widget.dart';
import '../../controller/cart_controller.dart';
import '../../controller/cart_extra_controller.dart';
import '../../model/cart_api_model.dart';
import 'cart_extras_dialog.dart';
import 'dotted_line_painter.dart';

class CartFoodListWidget extends StatelessWidget {
  const CartFoodListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<CartController>(
      id: 'cart_items',
      builder: (controller) {
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder:
              (context, index) => _buildCartItem(
                context,
                controller,
                controller.cartItems[index],
                responsive,
              ),
          separatorBuilder: (context, index) => const SizedBox.shrink(),
          itemCount: controller.cartItems.length,
        );
      },
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartController controller,
    CartItem cartItem,
    ResponsiveHelper responsive,
  ) {
    final scenario = _detectScenario(cartItem);

    return Container(
      width: responsive.screenWidth,
      padding: EdgeInsets.all(responsive.spacing20),
      margin: EdgeInsets.only(bottom: responsive.spacing20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: responsive.spacing24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMainContent(cartItem, controller, scenario, responsive),

          // ── Scenario 1: Food only → full-width "Customise" button ──────────
          if (scenario == 1) ...[
            SizedBox(height: responsive.spacing12),
            _buildCustomiseButton(context, cartItem, responsive),
          ],

          // ── Scenarios 2, 3, 4: divider + single "Add More" row at top ──────
          if (scenario != 1) ...[
            SizedBox(height: responsive.spacing20),
            _buildDivider(responsive),
            SizedBox(height: responsive.spacing16),
            // Single "Add More" link — sits at the top, applies to the whole card
            _buildSingleAddMoreRow(context, cartItem, responsive),
            SizedBox(height: responsive.spacing12),
          ],

          // ── Scenario 2: Add-ons list ───────────────────────────────────────
          if (scenario == 2) _buildAddOnsList(cartItem, controller, responsive),

          // ── Scenario 3: Customizations list ──────────────────────────────
          if (scenario == 3)
            _buildCustomizationsList(cartItem, controller, responsive),

          // ── Scenario 4: Customizations + Add-ons lists ────────────────────
          if (scenario == 4) ...[
            _buildCustomizationsSection(cartItem, controller, responsive),
            if (cartItem.addOns?.isNotEmpty ?? false) ...[
              SizedBox(height: responsive.spacing20),
              _buildDivider(responsive),
              SizedBox(height: responsive.spacing16),
              _buildAddOnsSection(cartItem, controller, responsive),
            ],
          ],
        ],
      ),
    );
  }

  int _detectScenario(CartItem item) {
    final hasCustomizations =
        item.customizations != null && item.customizations!.isNotEmpty;
    final hasAddOns = item.addOns != null && item.addOns!.isNotEmpty;

    if (!hasCustomizations && !hasAddOns) return 1;
    if (!hasCustomizations && hasAddOns) return 2;
    if (hasCustomizations && !hasAddOns) return 3;
    return 4;
  }

  // ── Single "Add More" row for scenarios 2, 3, 4 ───────────────────────────

  Widget _buildSingleAddMoreRow(
    BuildContext context,
    CartItem cartItem,
    ResponsiveHelper responsive,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _sectionTitle(_detectScenario(cartItem), cartItem),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: responsive.fontSize16,
          ),
        ),
        GestureDetector(
          onTap: () => _openExtrasDialog(context, cartItem),
          child: Text(
            'Add More',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: responsive.fontSize14,
              color: AppColor.appPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Label shown next to "Add More" depending on scenario
  String _sectionTitle(int scenario, CartItem cartItem) {
    if (scenario == 2) return 'Add Ons';
    if (scenario == 3) return 'Customizations';
    return 'Extras'; // scenario 4 — has both
  }

  // ── "Customise" button for Scenario 1 ─────────────────────────────────────

  Widget _buildCustomiseButton(
    BuildContext context,
    CartItem cartItem,
    ResponsiveHelper responsive,
  ) {
    return GestureDetector(
      onTap: () => _openExtrasDialog(context, cartItem),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: responsive.spacing10),
        decoration: BoxDecoration(
          color: AppColor.appPrimary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(responsive.spacing40),
          border: Border.all(
            color: AppColor.appPrimary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              size: responsive.spacing16,
              color: AppColor.appPrimary,
            ),
            SizedBox(width: responsive.spacing6),
            Text(
              'Customise',
              style: TextStyle(
                fontSize: responsive.fontSize13,
                fontWeight: FontWeight.w600,
                color: AppColor.appPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openExtrasDialog(BuildContext context, CartItem cartItem) {
    if (!Get.isRegistered<CartExtrasController>()) {
      Get.put(CartExtrasController());
    }
    final extrasController = Get.find<CartExtrasController>();
    extrasController.openExtrasDialog(cartItem);
    showCartExtrasDialog(context);
  }

  // ── Main content ────────────────────────────────────────────────────────────

  Widget _buildMainContent(
    CartItem cartItem,
    CartController controller,
    int scenario,
    ResponsiveHelper responsive,
  ) {
    return Row(
      children: [
        image(
          url: cartItem.foodImage ?? '',
          width: responsive.spacing80,
          height: responsive.spacing80,
          borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
        ),
        SizedBox(width: responsive.spacing20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemName(cartItem.foodName ?? '', responsive),
              if (cartItem.foodType != null)
                _buildItemCategory(cartItem.foodType ?? '', responsive),
              _buildPriceAndQuantity(
                cartItem,
                controller,
                scenario,
                responsive,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemName(String name, ResponsiveHelper responsive) {
    return Text(
      name,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: responsive.fontSize16,
        color: Colors.black,
      ),
      maxLines: 2,
      textAlign: TextAlign.start,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildItemCategory(String category, ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.only(top: responsive.spacing4),
      child: Text(
        category,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: responsive.fontSize14,
          color: AppColor.black.withOpacity(0.6),
        ),
        maxLines: 2,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPriceAndQuantity(
    CartItem cartItem,
    CartController controller,
    int scenario,
    ResponsiveHelper responsive,
  ) {
    if (scenario == 3 || scenario == 4) {
      return Padding(
        padding: EdgeInsets.only(top: responsive.spacing8),
        child: Text(
          'Rs.${formatPrice(cartItem.basePrice)}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: responsive.fontSize18,
            color: Colors.black,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: responsive.spacing8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Rs.${formatPrice(cartItem.basePrice)}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: responsive.fontSize18,
                color: Colors.black,
              ),
            ),
          ),
          GetBuilder<CartController>(
            id: 'cart_items',
            builder: (ctrl) {
              return QuantityControlWidget(
                quantity: cartItem.quantity ?? 1,
                onIncrease:
                    () => controller.updateItemQuantity(
                      cartItem.foodId ?? '',
                      (cartItem.quantity ?? 1) + 1,
                    ),
                onDecrease:
                    () => controller.updateItemQuantity(
                      cartItem.foodId ?? '',
                      (cartItem.quantity ?? 1) - 1,
                    ),
                showRemoveButton: true,
                buttonSize: responsive.spacing28,
                iconSize: responsive.spacing14,
                margin: const EdgeInsets.only(right: 0),
                isCompactMode: true,
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Add-ons (standalone list, no header — header is the shared row above) ──

  Widget _buildAddOnsSection(
    CartItem cartItem,
    CartController controller,
    ResponsiveHelper responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Add Ons',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: responsive.fontSize16,
          ),
        ),
        SizedBox(height: responsive.spacing12),
        _buildAddOnsList(cartItem, controller, responsive),
      ],
    );
  }

  Widget _buildAddOnsList(
    CartItem cartItem,
    CartController controller,
    ResponsiveHelper responsive,
  ) {
    final addOns = cartItem.addOns ?? [];
    if (addOns.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder:
          (context, index) =>
              _buildAddOnItem(cartItem, addOns[index], controller, responsive),
      separatorBuilder:
          (context, index) => SizedBox(height: responsive.spacing10),
      itemCount: addOns.length,
    );
  }

  Widget _buildAddOnItem(
    CartItem cartItem,
    AddOn addOn,
    CartController controller,
    ResponsiveHelper responsive,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing12,
        vertical: responsive.spacing10,
      ),
      decoration: BoxDecoration(
        color: AppColor.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(responsive.spacing12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addOn.name ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: responsive.fontSize14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: responsive.spacing4),
                Text(
                  'Rs.${formatPrice(addOn.price)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: responsive.fontSize12,
                    color: AppColor.black.withOpacity(0.6),
                  ),
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
                buttonSize: responsive.spacing24,
                iconSize: responsive.spacing12,
                margin: EdgeInsets.zero,
                isCompactMode: true,
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Customizations (standalone list, no header — header is the shared row above) ──

  Widget _buildCustomizationsSection(
    CartItem cartItem,
    CartController controller,
    ResponsiveHelper responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Customizations',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: responsive.fontSize16,
          ),
        ),
        SizedBox(height: responsive.spacing12),
        _buildCustomizationsList(cartItem, controller, responsive),
      ],
    );
  }

  Widget _buildCustomizationsList(
    CartItem cartItem,
    CartController controller,
    ResponsiveHelper responsive,
  ) {
    final customizations = cartItem.customizations ?? [];
    if (customizations.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder:
          (context, index) => _buildCustomizationItem(
            cartItem,
            customizations[index],
            controller,
            responsive,
          ),
      separatorBuilder:
          (context, index) => SizedBox(height: responsive.spacing10),
      itemCount: customizations.length,
    );
  }

  Widget _buildCustomizationItem(
    CartItem cartItem,
    AddOn customization,
    CartController controller,
    ResponsiveHelper responsive,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing12,
        vertical: responsive.spacing10,
      ),
      decoration: BoxDecoration(
        color: AppColor.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(responsive.spacing12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customization.name ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: responsive.fontSize14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: responsive.spacing4),
                Text(
                  'Rs.${formatPrice(customization.price)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: responsive.fontSize12,
                    color: AppColor.black.withOpacity(0.6),
                  ),
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
                buttonSize: responsive.spacing24,
                iconSize: responsive.spacing12,
                margin: EdgeInsets.zero,
                isCompactMode: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ResponsiveHelper responsive) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: DottedLinePainter(color: AppColor.black.withOpacity(0.1)),
      ),
    );
  }
}
