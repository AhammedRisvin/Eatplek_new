import 'package:eatplek_app/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      builder: (_) {
        final cartService = Get.find<CartService>();

        return Obx(() {
          final totalItems = cartService.itemCount.value;
          final totalPrice = cartService.subtotalPrice.value;

          if (totalItems == 0) return const SizedBox.shrink();

          final itemLabel = totalItems == 1 ? 'item' : 'items';

          return Container(
                width: Get.width,
                decoration: BoxDecoration(
                  color: AppColor.appPrimary,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(responsive.largeBorderRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.appPrimary.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                  left: responsive.spacing16,
                  right: responsive.spacing16,
                  top: responsive.spacing14,
                  bottom:
                      responsive.spacing16 +
                      MediaQuery.of(context).viewPadding.bottom,
                ),
                child: Row(
                  children: [
                    // ── Item count + price ─────────────────────────────────
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text(
                            text: '$totalItems $itemLabel added',
                            size: responsive.fontSize13,
                            fontWeight: FontWeight.w500,
                            color: AppColor.white.withOpacity(0.85),
                          ),
                          SizedBox(height: responsive.spacing3),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '₹${totalPrice.toStringAsFixed(2)}',
                              key: ValueKey(totalPrice),
                              style: TextStyle(
                                fontSize: responsive.fontSize18,
                                fontWeight: FontWeight.w700,
                                color: AppColor.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── View Cart button ───────────────────────────────────
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.cartView),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing16,
                          vertical: responsive.spacing10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(
                            responsive.largeBorderRadius,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            text(
                              text: 'View Cart',
                              size: responsive.fontSize13,
                              fontWeight: FontWeight.w700,
                              color: AppColor.appPrimary,
                            ),
                            SizedBox(width: responsive.spacing5),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: responsive.fontSize14,
                              color: AppColor.appPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .slideY(
                begin: 1,
                end: 0,
                duration: 300.ms,
                curve: Curves.easeOutCubic,
              )
              .fade(duration: 200.ms);
        });
      },
    );
  }
}
