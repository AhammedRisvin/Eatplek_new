import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import 'dotted_line_painter.dart';

class PriceSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double taxAmount;
  final double taxPercentage;
  final double packingCharge;
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
    this.deliveryFee = 0.0,
    this.taxAmount = 0.0,
    this.taxPercentage = 0.0,
    this.packingCharge = 0.0,
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
    return Container(
      width: context.wp(100),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin: margin ?? EdgeInsets.only(bottom: 100),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          priceRow(title: 'Subtotal', value: '$currency${subtotal.toInt()}', padding: EdgeInsets.only(bottom: 20)),

          // Delivery Fee
          if (showDeliveryFee && deliveryFee > 0)
            priceRow(
              title: customDeliveryTitle ?? 'Delivery Fee',
              value: '$currency${deliveryFee.toInt()}',
              padding: EdgeInsets.only(bottom: 20),
            ),

          // Taxes
          if (showTaxes && taxAmount > 0)
            priceRow(
              title: customTaxTitle ?? 'Taxes',
              value: '$currency${taxAmount.toInt()}',
              padding: EdgeInsets.only(bottom: 20),
            ),

          // Packing Charge
          if (showPackingCharge && packingCharge > 0)
            priceRow(
              title: customPackingTitle ?? 'Packing Charge',
              value: '$currency${packingCharge.toInt()}',
              padding: EdgeInsets.only(bottom: 20),
            ),

          // Promo Discount
          if (showPromoDiscount && promoDiscount > 0)
            priceRow(
              title: 'Discount${appliedPromoCode.isNotEmpty ? ' ($appliedPromoCode)' : ''}',
              value: '-$currency${promoDiscount.toInt()}',
              padding: EdgeInsets.only(bottom: 16),
              isDiscount: true,
            ),

          // Dotted line separator
          SizedBox(
            height: 1,
            width: double.infinity,
            child: CustomPaint(painter: DottedLinePainter(color: AppColor.black.withOpacity(0.1))),
          ),
          16.h,

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(text: 'Total', size: 16, fontWeight: FontWeight.w600),
              text(text: '$currency${totalAmount.toInt()}', size: 16, fontWeight: FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget priceRow({
    required String title,
    required String value,
    required EdgeInsetsGeometry padding,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text(text: title, size: 16, fontWeight: FontWeight.w500, color: AppColor.black.withOpacity(0.6)),
          text(text: value, size: 16, fontWeight: FontWeight.w500, color: isDiscount ? discountColor : null),
        ],
      ),
    );
  }
}
