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
    this.deliveryFee,
    this.taxAmount,
    this.packingCharge,
    this.promoDiscount = 0.0,
    this.appliedPromoCode = '',
    this.currency = '₹',
    this.showDeliveryFee = true,
    this.showTaxes = true,
    this.showPackingCharge = true,
    this.showPromoDiscount = true,
    this.margin,
    this.customDeliveryTitle,
    this.customTaxTitle,
    this.customPackingTitle,
    this.discountColor,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final effectiveDiscountColor = discountColor ?? const Color(0xFF00b894);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.spacing20),
      margin: margin ?? EdgeInsets.only(bottom: responsive.spacing100),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                'Bill Details',
                style: TextStyle(
                  fontSize: responsive.fontSize15,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing16),

          // Subtotal
          _row(
            'Subtotal',
            '$currency${subtotal.toInt()}',
            responsive: responsive,
          ),

          // Delivery fee
          if (showDeliveryFee && deliveryFee != null)
            _row(
              customDeliveryTitle ?? 'Delivery Fee',
              '$currency${deliveryFee!.toInt()}',
              responsive: responsive,
            ),

          // Tax
          if (showTaxes && taxAmount != null)
            _row(
              customTaxTitle ?? 'Taxes & Charges',
              '$currency${taxAmount!.toInt()}',
              responsive: responsive,
            ),

          // Packing charge
          if (showPackingCharge && packingCharge != null)
            _row(
              customPackingTitle ?? 'Packing Charge',
              '$currency${packingCharge!.toInt()}',
              responsive: responsive,
            ),

          // Promo discount
          if (showPromoDiscount && promoDiscount > 0) ...[
            SizedBox(height: responsive.spacing4),
            _row(
              appliedPromoCode.isNotEmpty
                  ? 'Discount ($appliedPromoCode)'
                  : 'Discount',
              '-$currency${promoDiscount.toInt()}',
              responsive: responsive,
              valueColor: effectiveDiscountColor,
              showSavingsBadge: true,
            ),
          ],

          SizedBox(height: responsive.spacing12),

          // Dotted divider
          SizedBox(
            height: 1,
            width: double.infinity,
            child: CustomPaint(
              painter: DottedLinePainter(
                color: AppColor.black.withOpacity(0.1),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing14),

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To Pay',
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
              ),
              Text(
                '$currency${totalAmount.toInt()}',
                style: TextStyle(
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w800,
                  color: AppColor.appPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(
    String title,
    String value, {
    required ResponsiveHelper responsive,
    Color? valueColor,
    bool showSavingsBadge = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.fontSize13,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.55),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSavingsBadge)
                Container(
                  margin: EdgeInsets.only(right: responsive.spacing6),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing6,
                    vertical: responsive.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00b894).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      responsive.largeBorderRadius,
                    ),
                  ),
                  child: Text(
                    'Saving!',
                    style: TextStyle(
                      fontSize: responsive.fontSize9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00b894),
                    ),
                  ),
                ),
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColor.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
