import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/price_formatter.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../../cart/controller/cart_service.dart';
import '../../../restaurant_detail_view/view/widget/quantity_control_widget.dart';
import '../../model/today_offers_model.dart';

class OfferFoodCard extends StatelessWidget {
  final OfferFood offer;
  final int animationIndex;
  final VoidCallback? onActionTap;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  const OfferFoodCard({
    super.key,
    required this.offer,
    this.animationIndex = 0,
    this.onActionTap,
    this.onIncrease,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final food = offer.food;
    final hasOptions =
        (food.customizations?.isNotEmpty ?? false) ||
        (food.addOns?.isNotEmpty ?? false);

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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(responsive.cardBorderRadius),
                    ),
                    child: image(
                      url: food.foodImage ?? '',
                      height: responsive.cardImageHeight,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: responsive.spacing8,
                    left: responsive.spacing8,
                    child: _OfferBadge(label: offer.offerLabel),
                  ),
                  if ((food.shareLink ?? '').isNotEmpty)
                    Positioned(
                      top: responsive.spacing8,
                      right: responsive.spacing8,
                      child: _ShareButton(onTap: _shareFood),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(responsive.spacing10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(
                        text: _capitalize(food.foodName ?? 'Food item'),
                        size: responsive.fontSize13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.black,
                        maxLines: 2,
                        overFlow: TextOverflow.ellipsis,
                      ),
                      if (_hasRestaurantMeta) ...[
                        SizedBox(height: responsive.spacing4),
                        _RestaurantMetaRow(offer: offer),
                      ],
                      SizedBox(height: responsive.spacing6),
                      _PriceRow(offer: offer),
                      const Spacer(),
                      SizedBox(height: responsive.spacing8),
                      _OfferAction(
                        offer: offer,
                        hasOptions: hasOptions,
                        onActionTap: onActionTap,
                        onIncrease: onIncrease,
                        onDecrease: onDecrease,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 50 * animationIndex))
        .fade(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  bool get _hasRestaurantMeta {
    return (offer.vendorName ?? '').isNotEmpty ||
        (offer.vendorPlace ?? '').isNotEmpty ||
        offer.distanceKm != null;
  }

  Future<void> _shareFood() async {
    final link = offer.food.shareLink;
    if (link == null || link.isEmpty) return;

    final name = offer.food.foodName ?? 'this offer';
    await Share.share('Check out $name on EatPlek!\n$link', subject: name);
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _OfferAction extends StatelessWidget {
  final OfferFood offer;
  final bool hasOptions;
  final VoidCallback? onActionTap;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  const _OfferAction({
    required this.offer,
    required this.hasOptions,
    required this.onActionTap,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final foodId = offer.food.foodId ?? '';
    if (foodId.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      final cartService = Get.find<CartService>();
      final quantity = cartService.getFoodQuantity(foodId);
      final inCart = quantity > 0 || cartService.foodHasCustomizations(foodId);

      if (hasOptions) {
        final label = inCart ? 'Edit' : 'Add';
        final background =
            inCart
                ? AppColor.appPrimary.withOpacity(0.12)
                : AppColor.appPrimary;
        final foreground = inCart ? AppColor.appPrimary : AppColor.white;

        return GestureDetector(
          onTap: onActionTap,
          child: Container(
            width: double.infinity,
            height: responsive.spacing36,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
              border:
                  inCart
                      ? Border.all(color: AppColor.appPrimary, width: 1.2)
                      : null,
            ),
            child: Center(
              child: text(
                text: label,
                size: responsive.fontSize12,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        );
      }

      return SizedBox(
        height: responsive.spacing36,
        child: QuantityControlWidget(
          quantity: quantity,
          onIncrease: onIncrease ?? () {},
          onDecrease: onDecrease ?? () {},
          showRemoveButton: true,
          buttonSize: responsive.spacing28,
          iconSize: responsive.fontSize13,
          addButtonText: 'Add',
        ),
      );
    });
  }
}

class _RestaurantMetaRow extends StatelessWidget {
  final OfferFood offer;

  const _RestaurantMetaRow({required this.offer});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final restaurantText = _restaurantText;
    final distanceText = _distanceText;

    return Row(
      children: [
        if (restaurantText.isNotEmpty)
          Expanded(
            child: text(
              text: restaurantText,
              size: responsive.fontSize13,
              fontWeight: FontWeight.w800,
              color: AppColor.black.withOpacity(0.72),
              maxLines: 2,
              overFlow: TextOverflow.ellipsis,
            ),
          )
        else
          const Spacer(),
        if (distanceText.isNotEmpty) ...[
          SizedBox(width: responsive.spacing5),
          Icon(
            Icons.near_me_rounded,
            size: responsive.fontSize10,
            color: AppColor.black.withOpacity(0.34),
          ),
          SizedBox(width: responsive.spacing2),
          text(
            text: distanceText,
            size: responsive.fontSize10,
            fontWeight: FontWeight.w600,
            color: AppColor.black.withOpacity(0.42),
            maxLines: 1,
            overFlow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  String get _restaurantText {
    final name = offer.vendorName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    return offer.vendorPlace?.trim() ?? '';
  }

  String get _distanceText {
    final distance = offer.distanceKm;
    if (distance == null || distance <= 0) return '';
    if (distance < 10) return '${distance.toStringAsFixed(1)} km';
    return '${distance.toStringAsFixed(0)} km';
  }
}

class _OfferBadge extends StatelessWidget {
  final String? label;

  const _OfferBadge({this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: text(
        text: (label == null || label!.isEmpty) ? 'Offer' : label,
        size: 10,
        fontWeight: FontWeight.w700,
        color: AppColor.white,
        maxLines: 1,
        overFlow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ShareButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColor.white.withOpacity(0.94),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: const Icon(
          Icons.share_outlined,
          size: 16,
          color: AppColor.appPrimary,
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final OfferFood offer;

  const _PriceRow({required this.offer});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final food = offer.food;
    final foodPrice =
        food.foodPrice ??
        food.discountPrice ??
        _asDouble(food.specialOfferPrice) ??
        0.0;
    final actualPrice = food.actualPrice ?? foodPrice;
    final hasDiscount = actualPrice != foodPrice;

    return Row(
      children: [
        text(
          text: 'Rs ${formatPrice(foodPrice)}',
          size: responsive.fontSize13,
          fontWeight: FontWeight.w700,
          color: AppColor.appPrimary,
        ),
        if (hasDiscount) ...[
          SizedBox(width: responsive.spacing6),
          text(
            text: 'Rs ${formatPrice(actualPrice)}',
            size: responsive.fontSize10,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.35),
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColor.black.withOpacity(0.35),
          ),
          SizedBox(width: responsive.spacing5),
          Flexible(
            child: text(
              text: '${_discountPercent(actualPrice, foodPrice).toInt()}% off',
              size: responsive.fontSize9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF6B6B),
              maxLines: 1,
              overFlow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  double _discountPercent(double actual, double offer) {
    if (actual <= 0) return 0;
    return ((actual - offer) / actual) * 100;
  }
}
