import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../model/today_offers_model.dart';

class OfferFoodCard extends StatelessWidget {
  final OfferFood offer;
  final int animationIndex;

  const OfferFoodCard({
    super.key,
    required this.offer,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final food = offer.food;

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
              Padding(
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
        Icon(
          Icons.storefront_rounded,
          size: responsive.fontSize11,
          color: AppColor.appPrimary.withOpacity(0.55),
        ),
        SizedBox(width: responsive.spacing3),
        if (restaurantText.isNotEmpty)
          Expanded(
            child: text(
              text: restaurantText,
              size: responsive.fontSize10,
              fontWeight: FontWeight.w500,
              color: AppColor.black.withOpacity(0.48),
              maxLines: 1,
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
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
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
    final offerPrice =
        _asDouble(food.specialOfferPrice) ??
        food.discountPrice ??
        food.foodPrice ??
        0.0;
    final actualPrice = food.actualPrice ?? food.foodPrice ?? offerPrice;
    final hasDiscount = actualPrice > offerPrice;

    return Row(
      children: [
        text(
          text: 'Rs ${offerPrice.toInt()}',
          size: responsive.fontSize13,
          fontWeight: FontWeight.w700,
          color: AppColor.appPrimary,
        ),
        if (hasDiscount) ...[
          SizedBox(width: responsive.spacing6),
          text(
            text: 'Rs ${actualPrice.toInt()}',
            size: responsive.fontSize10,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.35),
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColor.black.withOpacity(0.35),
          ),
          SizedBox(width: responsive.spacing5),
          Flexible(
            child: text(
              text:
                  '${_discountPercent(actualPrice, offerPrice).toInt()}% off',
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
