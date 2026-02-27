import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';

import 'dotted_line_painter.dart';

class PriceSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double? deliveryFee;
  final double? taxAmount;
  final double? packingCharge;
  final double promoDiscount;
  final String appliedPromoCode;
  final double totalAmount;
  final String currency;
  final bool showDeliveryFee;
  final bool showTaxes;
  final bool showPackingCharge;
  final bool showPromoDiscount;
  final EdgeInsetsGeometry? margin;
  final String? customDeliveryTitle;
  final String? customTaxTitle;
  final String? customPackingTitle;
  final Color? discountColor;

  const PriceSummaryWidget({
    super.key,
    required this.subtotal,
    required this.totalAmount,
    this.deliveryFee, // nullable — show if not null (even if 0)
    this.taxAmount, // nullable — show if not null (even if 0)
    this.packingCharge, // nullable — show if not null (even if 0)
    this.promoDiscount = 0.0,
    this.appliedPromoCode = '',
    this.currency = 'Rs.',
    this.showDeliveryFee = true,
    this.showTaxes = true,
    this.showPackingCharge = true,
    this.showPromoDiscount = true,
    this.margin,
    this.customDeliveryTitle,
    this.customTaxTitle,
    this.customPackingTitle,
    this.discountColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.screenWidth,
      padding: EdgeInsets.symmetric(
        vertical: responsive.spacing20,
        horizontal: responsive.spacing20,
      ),
      margin: margin ?? EdgeInsets.only(bottom: responsive.spacing100),
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
          // ── Subtotal ──────────────────────────────────────────────────────
          _priceRow(
            title: 'Subtotal',
            value: '$currency${subtotal.toInt()}',
            padding: EdgeInsets.only(bottom: responsive.spacing20),
            responsive: responsive,
          ),

          // ── Delivery Fee — show if not null (even when value is 0) ────────
          if (showDeliveryFee && deliveryFee != null)
            _priceRow(
              title: customDeliveryTitle ?? 'Delivery Fee',
              value: '$currency${deliveryFee!.toInt()}',
              padding: EdgeInsets.only(bottom: responsive.spacing20),
              responsive: responsive,
            ),

          // ── Taxes — show if not null (even when value is 0) ───────────────
          if (showTaxes && taxAmount != null)
            _priceRow(
              title: customTaxTitle ?? 'Taxes',
              value: '$currency${taxAmount!.toInt()}',
              padding: EdgeInsets.only(bottom: responsive.spacing20),
              responsive: responsive,
            ),

          // ── Packing Charge — show if not null (even when value is 0) ──────
          if (showPackingCharge && packingCharge != null)
            _priceRow(
              title: customPackingTitle ?? 'Packing Charge',
              value: '$currency${packingCharge!.toInt()}',
              padding: EdgeInsets.only(bottom: responsive.spacing20),
              responsive: responsive,
            ),

          // ── Promo Discount — only show when actually applied (> 0) ────────
          if (showPromoDiscount && promoDiscount > 0)
            _priceRow(
              title:
                  'Discount${appliedPromoCode.isNotEmpty ? ' ($appliedPromoCode)' : ''}',
              value: '-$currency${promoDiscount.toInt()}',
              padding: EdgeInsets.only(bottom: responsive.spacing16),
              isDiscount: true,
              responsive: responsive,
            ),

          // ── Dotted separator ──────────────────────────────────────────────
          SizedBox(
            height: 1,
            width: double.infinity,
            child: CustomPaint(
              painter: DottedLinePainter(
                color: AppColor.black.withOpacity(0.1),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing16),

          // ── Total ─────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '$currency${totalAmount.toInt()}',
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow({
    required String title,
    required String value,
    required EdgeInsetsGeometry padding,
    required ResponsiveHelper responsive,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.fontSize16,
              fontWeight: FontWeight.w500,
              color: AppColor.black.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize16,
              fontWeight: FontWeight.w500,
              color: isDiscount ? discountColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
