import 'package:eatplek_app/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../../cart/controller/cart_service.dart';
import '../../controller/restaurant_detail_view_controller.dart';

class BottomCartBar extends StatelessWidget {
  const BottomCartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<RestaurantDetailViewController>(
      id: 'bottom_cart_bar',
      builder: (controller) {
        final cartService = Get.find<CartService>();

        return Obx(() {
          final totalItems = cartService.itemCount.value;
          final totalPrice = cartService.totalPrice.value;

          if (totalItems == 0) {
            debugPrint('🛒 BottomCartBar: Cart empty, hiding bar');
            return SizedBox.shrink();
          }

          final itemText = totalItems == 1 ? 'item' : 'items';

          debugPrint('🛒 BottomCartBar: Showing - $totalItems $itemText, ₹${totalPrice.toStringAsFixed(2)}');

          return AnimatedSlide(
            duration: Duration(milliseconds: 300),
            offset: totalItems > 0 ? Offset.zero : Offset(0, 2),
            child: Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.largeBorderRadius)),
                boxShadow: [
                  BoxShadow(color: AppColor.appPrimary.withOpacity(0.3), blurRadius: 20, offset: Offset(0, -5)),
                ],
              ),
              padding: EdgeInsets.only(
                left: responsive.spacing16,
                right: responsive.spacing16,
                top: responsive.spacing12,
                bottom: responsive.spacing16 + MediaQuery.of(context).viewPadding.bottom,
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
                          size: responsive.fontSize14,
                          fontWeight: FontWeight.w500,
                          color: AppColor.white,
                        ),
                        SizedBox(height: responsive.spacing4),
                        text(
                          text: '₹${totalPrice.toStringAsFixed(0)}',
                          size: responsive.fontSize18,
                          fontWeight: FontWeight.w600,
                          color: AppColor.white,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      debugPrint('🛒 Navigating to cart');
                      Get.toNamed(Routes.cartView);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: responsive.spacing16, vertical: responsive.spacing10),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          text(
                            text: 'View Cart',
                            size: responsive.fontSize14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.appPrimary,
                          ),
                          SizedBox(width: responsive.spacing4),
                          Icon(Icons.arrow_forward, size: responsive.fontSize14, color: AppColor.appPrimary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
