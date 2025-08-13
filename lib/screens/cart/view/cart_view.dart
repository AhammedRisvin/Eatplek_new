import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controller/cart_controller.dart';
import 'widget/additional_notes_widget.dart';
import 'widget/cart_food_list.dart';
import 'widget/empty_cart.dart';
import 'widget/friend_invitation_card.dart';
import 'widget/price_summary_widget.dart';
import 'widget/promo_code_widget.dart';

class CartView extends StatefulWidget {
  final bool isFromBottomNav;
  const CartView({super.key, this.isFromBottomNav = false});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        title: text(text: 'Cart', size: 18, fontWeight: FontWeight.w600),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.5),
              ),
              child: SvgPicture.string(arrowBack2),
            ),
          ),
        ),
      ),
      body: GetBuilder<CartController>(
        id: 'empty_cart',
        init: CartController(),
        builder: (controller) {
          if (controller.isCartEmpty) {
            return EmptyCartWidget();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CartFoodListWidget(),
                PromoCodeWidget(),
                FriendInvitationCard(),
                AdditionalNotesWidget(),
                GetBuilder<CartController>(
                  id: 'price_summary',
                  builder: (controller) {
                    return PriceSummaryWidget(
                      subtotal: controller.subtotal,
                      deliveryFee: controller.deliveryFee,
                      taxAmount: controller.taxAmount,
                      taxPercentage: controller.taxPercentage,
                      packingCharge: controller.packingCharge,
                      promoDiscount: controller.promoDiscount,
                      appliedPromoCode: controller.appliedPromoCode,
                      totalAmount: controller.totalAmount,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: GetBuilder<CartController>(
        id: 'empty_cart',
        builder: (controller) {
          if (controller.isCartEmpty) {
            return SizedBox.shrink();
          }

          return Container(
            width: context.wp(100),
            color: AppColor.scaffoldColor,
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: widget.isFromBottomNav ? 100 : 20),
            child: button(
              name: 'Place Order',
              width: context.wp(100),
              fontSize: 18,
              height: 60,
              fontWeight: FontWeight.w600,
              borderRadius: BorderRadius.circular(100),
              onTap: () => Get.find<CartController>().placeOrder(),
            ),
          );
        },
      ),
    );
  }
}
