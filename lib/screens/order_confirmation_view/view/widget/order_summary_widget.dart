import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/app_color.dart';
import '../../controller/order_confirmation_controller.dart';

class OrderSummaryWidget extends StatelessWidget {
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

  const OrderSummaryWidget({
    super.key,
    this.mainDishes = const [],
    this.addOns = const [],
    required this.totalAmount,
    this.title = 'Order Summary',
    this.showMainDishesSection = true,
    this.showAddOnsSection = true,
    this.showTotalSection = true,
    this.mainDishesTitle = 'Main Dishes',
    this.addOnsTitle = 'Add-ons & Customizations',
    this.totalTitle = 'Total Amount',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.wp(100),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[text(text: title!, size: 16, fontWeight: FontWeight.w600), 16.h],

          if (showMainDishesSection && mainDishes.isNotEmpty) ...[
            text(text: mainDishesTitle, size: 14, fontWeight: FontWeight.w600, color: AppColor.appPrimary),
            8.h,
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = mainDishes[index];
                return _buildOrderItem(item, showQuantity: true);
              },
              separatorBuilder: (context, index) => 12.h,
              itemCount: mainDishes.length,
            ),
            16.h,
          ],

          // ✅ ADD-ONS & CUSTOMIZATIONS SECTION (With Quantities)
          if (showAddOnsSection && addOns.isNotEmpty) ...[
            text(text: addOnsTitle, size: 14, fontWeight: FontWeight.w600, color: Colors.orange),
            8.h,
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = addOns[index];
                // ✅ Show quantity for all add-ons and customizations
                return _buildOrderItem(item, showQuantity: true);
              },
              separatorBuilder: (context, index) => 12.h,
              itemCount: addOns.length,
            ),
            16.h,
          ],

          // ✅ TOTAL SECTION
          if (showTotalSection) ...[
            Divider(color: AppColor.black.withOpacity(0.1)),
            8.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(text: totalTitle, size: 16, fontWeight: FontWeight.w600),
                text(
                  text: '₹ ${totalAmount.toStringAsFixed(2)}',
                  size: 16,
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
  Widget _buildOrderItem(OrderItem item, {required bool showQuantity}) {
    return Row(
      children: [
        image(url: item.imageUrl, width: 50, height: 50, borderRadius: BorderRadius.circular(10)),
        14.w,
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
                      size: 14,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
                  ),
                  // ✅ Show quantity for all items (main dishes and add-ons)
                  if (showQuantity && item.quantity > 0)
                    text(text: 'x${item.quantity}', size: 14, fontWeight: FontWeight.w500, color: AppColor.appPrimary),
                ],
              ),
              6.h,
              if (item.price > 0)
                text(
                  text:
                      showQuantity
                          ? '₹ ${(item.price * item.quantity).toStringAsFixed(2)}'
                          : '₹ ${item.price.toStringAsFixed(2)}',
                  size: 14,
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
