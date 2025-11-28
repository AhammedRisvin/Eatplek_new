import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';

class BottomCartBar extends StatelessWidget {
  const BottomCartBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'bottom_cart_bar',
      builder: (controller) {
        // Get cart info from API response
        final cartDisplayInfo = controller.getCartDisplayInfo();

        if (cartDisplayInfo == null) {
          debugPrint('🛒 BottomCartBar: No cart data, hiding bar');
          return SizedBox.shrink();
        }

        final totalItems = cartDisplayInfo['itemCount'] as int? ?? 0;
        final totalPrice = cartDisplayInfo['totalPrice'] as double? ?? 0.0;

        if (totalItems == 0) {
          debugPrint('🛒 BottomCartBar: Cart empty, hiding bar');
          return SizedBox.shrink();
        }

        final itemText = totalItems == 1 ? 'item' : 'items';

        debugPrint('🛒 BottomCartBar: Showing - $totalItems $itemText, ₹$totalPrice');

        return AnimatedSlide(
          duration: Duration(milliseconds: 300),
          offset: totalItems > 0 ? Offset.zero : Offset(0, 2),
          child: Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: AppColor.appPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: AppColor.appPrimary.withOpacity(0.3), blurRadius: 20, offset: Offset(0, -5)),
              ],
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(
                        text: '$totalItems $itemText added',
                        size: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColor.white,
                      ),
                      4.h,
                      text(
                        text: '₹${totalPrice.toStringAsFixed(0)}',
                        size: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColor.white,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    debugPrint('📋 View Cart button tapped');
                    debugPrint('🛒 Cart Items: ${cartDisplayInfo['items']}');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.circular(100)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        text(text: 'View Cart', size: 14, fontWeight: FontWeight.w600, color: AppColor.appPrimary),
                        4.w,
                        Icon(Icons.arrow_forward, size: 14, color: AppColor.appPrimary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
