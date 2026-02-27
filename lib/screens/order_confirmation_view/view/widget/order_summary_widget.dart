import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/order_confirmation_controller.dart';

class ResponsiveOrderSummaryWidget extends StatelessWidget {
  final List<OrderItem> mainDishes;
  final List<OrderItem> addOns;
  final double totalAmount;
  final String? title;
  final bool showMainDishesSection;
  final bool showAddOnsSection;
  final bool showTotalSection;
  final String mainDishesTitle;
  final String addOnsTitle;
  final String totalTitle;

  const ResponsiveOrderSummaryWidget({
    super.key,
    this.mainDishes = const [],
    this.addOns = const [],
    required this.totalAmount,
    this.title = 'Order Summary',
    this.showMainDishesSection = true,
    this.showAddOnsSection = true,
    this.showTotalSection = true,
    this.mainDishesTitle = 'Items',
    this.addOnsTitle = 'Add-ons & Customizations',
    this.totalTitle = 'Total Amount',
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.containerPadding,
      margin: EdgeInsets.only(bottom: responsive.spacing10),
      decoration: responsive.responsiveContainer(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            text(text: title!, size: responsive.fontSize16, fontWeight: FontWeight.w600),
            SizedBox(height: responsive.spacing16),
          ],

          if (showMainDishesSection && mainDishes.isNotEmpty) ...[
            text(
              text: mainDishesTitle,
              size: responsive.fontSize14,
              fontWeight: FontWeight.w600,
              color: AppColor.appPrimary,
            ),
            SizedBox(height: responsive.spacing8),
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = mainDishes[index];
                return _buildOrderItem(item, responsive, showQuantity: true);
              },
              separatorBuilder: (context, index) => SizedBox(height: responsive.spacing12),
              itemCount: mainDishes.length,
            ),
            SizedBox(height: responsive.spacing16),
          ],

          // ✅ ADD-ONS & CUSTOMIZATIONS SECTION (With Quantities)
          if (showAddOnsSection && addOns.isNotEmpty) ...[
            text(text: addOnsTitle, size: responsive.fontSize14, fontWeight: FontWeight.w600, color: Colors.orange),
            SizedBox(height: responsive.spacing8),
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = addOns[index];
                return _buildOrderItem(item, responsive, showQuantity: true);
              },
              separatorBuilder: (context, index) => SizedBox(height: responsive.spacing12),
              itemCount: addOns.length,
            ),
            SizedBox(height: responsive.spacing16),
          ],

          // ✅ TOTAL SECTION
          if (showTotalSection) ...[
            Divider(color: AppColor.black.withOpacity(0.1)),
            SizedBox(height: responsive.spacing8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(text: totalTitle, size: responsive.fontSize16, fontWeight: FontWeight.w600),
                text(
                  text: '₹ ${totalAmount.toStringAsFixed(2)}',
                  size: responsive.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.appPrimary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ Build individual order item with proper display
  Widget _buildOrderItem(OrderItem item, ResponsiveHelper responsive, {required bool showQuantity}) {
    return Row(
      children: [
        image(
          url: item.imageUrl,
          width: responsive.spacing50,
          height: responsive.spacing50,
          borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
        ),
        SizedBox(width: responsive.spacing14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name with quantity
              Row(
                children: [
                  Expanded(
                    child: text(
                      text: item.name,
                      size: responsive.fontSize14,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
                  ),
                  // ✅ Show quantity for all items (main dishes and add-ons)
                  if (showQuantity && item.quantity > 0)
                    text(
                      text: 'x${item.quantity}',
                      size: responsive.fontSize14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.appPrimary,
                    ),
                ],
              ),
              SizedBox(height: responsive.spacing6),
              if (item.price > 0)
                text(
                  text:
                      showQuantity
                          ? '₹ ${(item.price * item.quantity).toStringAsFixed(2)}'
                          : '₹ ${item.price.toStringAsFixed(2)}',
                  size: responsive.fontSize14,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
