import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import '../../model/restaurent_details_model.dart';
import 'food_details_bottom_sheet.dart';
import 'quantity_control_widget.dart';

class FoodWidget extends StatelessWidget {
  final Food foodItem;
  final int animationIndex;

  const FoodWidget({
    super.key,
    required this.foodItem,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final controller = Get.find<RestaurantDetailViewController>();
    final hasCustomizations = foodItem.customizations?.isNotEmpty ?? false;
    final hasAddOns = foodItem.addOns?.isNotEmpty ?? false;
    final foodName = _capitalize(foodItem.foodName ?? '');

    return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            color: AppColor.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image ──────────────────────────────────────────────────────
              _buildImage(
                context,
                controller,
                hasCustomizations,
                hasAddOns,
                responsive,
              ),

              // ── Details ────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(responsive.spacing10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Veg / non-veg indicator + name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVegIndicator(responsive),
                        SizedBox(width: responsive.spacing5),
                        Expanded(
                          child: text(
                            text: foodName,
                            size: responsive.fontSize13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.black,
                            maxLines: 2,
                            overFlow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.spacing6),

                    // Price
                    _buildPrice(responsive),
                    SizedBox(height: responsive.spacing8),

                    // Add / Edit / Quantity control
                    _buildAction(
                      context,
                      controller,
                      hasCustomizations,
                      hasAddOns,
                      responsive,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 50 * animationIndex))
        .fade(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  // ── Veg indicator dot ─────────────────────────────────────────────────────
  Widget _buildVegIndicator(ResponsiveHelper responsive) {
    // Food model has no foodType field — show veg indicator by default
    // const isVeg = false;
    return Container(
      width: responsive.spacing12,
      height: responsive.spacing12,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(
            0xFF27ae60,
          ), // isVeg ? const Color(0xFF27ae60) : const Color(0xFFe74c3c),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Container(
          width: responsive.spacing6,
          height: responsive.spacing6,
          decoration: BoxDecoration(
            color: const Color(
              0xFF27ae60,
            ), // isVeg ? const Color(0xFF27ae60) : const Color(0xFFe74c3c),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // ── Food image ────────────────────────────────────────────────────────────
  Widget _buildImage(
    BuildContext context,
    RestaurantDetailViewController controller,
    bool hasCustomizations,
    bool hasAddOns,
    ResponsiveHelper responsive,
  ) {
    return GestureDetector(
      onTap:
          () => _openSheet(
            context,
            controller,
            hasCustomizations,
            hasAddOns,
            responsive,
            isEdit: false,
          ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(responsive.cardBorderRadius),
            ),
            child: image(
              url: foodItem.foodImage ?? '',
              height: responsive.cardImageHeight,
              width: double.infinity,
            ),
          ),
          // Share button overlay
          Positioned(
            top: responsive.spacing8,
            right: responsive.spacing8,
            child: GestureDetector(
              onTap: _shareFood,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing7,
                  vertical: responsive.spacing5,
                ),
                decoration: BoxDecoration(
                  color: AppColor.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(
                    responsive.largeBorderRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.share_outlined,
                      size: responsive.fontSize11,
                      color: AppColor.appPrimary,
                    ),
                    SizedBox(width: responsive.spacing3),
                    text(
                      text: 'Share',
                      size: responsive.fontSize9,
                      fontWeight: FontWeight.w600,
                      color: AppColor.appPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Price section ─────────────────────────────────────────────────────────
  Widget _buildPrice(ResponsiveHelper responsive) {
    final discounted = (foodItem.discountPrice ?? foodItem.foodPrice ?? 0);
    final actual = (foodItem.actualPrice ?? foodItem.foodPrice ?? 0);
    final hasDiscount = actual > discounted;

    return Row(
      children: [
        text(
          text: '₹${discounted.toInt()}',
          size: responsive.fontSize13,
          fontWeight: FontWeight.w700,
          color: AppColor.appPrimary,
        ),
        if (hasDiscount) ...[
          SizedBox(width: responsive.spacing6),
          text(
            text: '₹${actual.toInt()}',
            size: responsive.fontSize10,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.35),
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColor.black.withOpacity(0.35),
          ),
          SizedBox(width: responsive.spacing5),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing5,
              vertical: responsive.spacing2,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(responsive.spacing3),
            ),
            child: text(
              text:
                  '${_calcDiscount(actual.toDouble(), discounted.toDouble()).toInt()}% off',
              size: responsive.fontSize9,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF6B6B),
            ),
          ),
        ],
      ],
    );
  }

  // ── Action button ─────────────────────────────────────────────────────────
  Widget _buildAction(
    BuildContext context,
    RestaurantDetailViewController controller,
    bool hasCustomizations,
    bool hasAddOns,
    ResponsiveHelper responsive,
  ) {
    final foodId = foodItem.foodId ?? '';
    if (foodId.isEmpty) return const SizedBox.shrink();

    final isScenario1 = !hasCustomizations && !hasAddOns;

    if (isScenario1) {
      return Obx(() {
        final qty = controller.cartFoodQuantity[foodId] ?? 0;
        return SizedBox(
          height: responsive.spacing36,
          child: QuantityControlWidget(
            quantity: qty,
            onIncrease: () => controller.increaseScenario1Quantity(foodId),
            onDecrease: () => controller.decreaseScenario1Quantity(foodId),
            showRemoveButton: true,
            buttonSize: responsive.spacing28,
            iconSize: responsive.fontSize13,
            addButtonText: 'Add',
          ),
        );
      });
    }

    return Obx(() {
      final inCart =
          (controller.cartFoodQuantity[foodId] ?? 0) > 0 ||
          (controller.cartCustomizationQuantity[foodId]?.values.any(
                (q) => q > 0,
              ) ??
              false);

      final isEdit = inCart;
      final label = isEdit ? 'Edit' : 'Add';
      final bg =
          isEdit ? AppColor.appPrimary.withOpacity(0.12) : AppColor.appPrimary;
      final fg = isEdit ? AppColor.appPrimary : AppColor.white;

      return GestureDetector(
        onTap:
            () => _openSheet(
              context,
              controller,
              hasCustomizations,
              hasAddOns,
              responsive,
              isEdit: isEdit,
            ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: responsive.spacing36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            color: bg,
            border:
                isEdit
                    ? Border.all(color: AppColor.appPrimary, width: 1.2)
                    : null,
            boxShadow:
                isEdit
                    ? null
                    : [
                      BoxShadow(
                        color: AppColor.appPrimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Center(
            child: text(
              text: label,
              size: responsive.fontSize12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      );
    });
  }

  void _openSheet(
    BuildContext context,
    RestaurantDetailViewController controller,
    bool hasCustomizations,
    bool hasAddOns,
    ResponsiveHelper responsive, {
    required bool isEdit,
  }) {
    controller.selectFoodItem(foodItem, isEdit: isEdit);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (_) => const FoodDetailsBottomSheet(),
    ).then((_) => controller.resetBottomSheetState());
  }

  void _shareFood() {
    if (foodItem.shareLink?.isNotEmpty ?? false) {
      Get.snackbar(
        'Share',
        'Sharing: ${foodItem.foodName}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  double _calcDiscount(double actual, double discounted) {
    if (actual == 0) return 0;
    return ((actual - discounted) / actual) * 100;
  }
}
