import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controller/cart_controller.dart';
import 'widget/additional_notes_widget.dart';
import 'widget/cart_food_list.dart';
import 'widget/empty_cart.dart';
import 'widget/price_summary_widget.dart';

class CartView extends StatefulWidget {
  final bool isFromBottomNav;
  const CartView({super.key, this.isFromBottomNav = false});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    super.initState();
    // Note: CartController is already initialized with Get.find() in CartView
    // API call happens in CartController.onInit()
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ✅ FIXED: Use WillPopScope to handle back navigation properly
      onWillPop: () async {
        // ✅ Use Navigator.pop instead of Get.back to avoid snackbar controller error
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 80,
          centerTitle: widget.isFromBottomNav ? true : false,
          title: text(text: 'Cart', size: 18, fontWeight: FontWeight.w600),
          leading:
              widget.isFromBottomNav
                  ? SizedBox.shrink()
                  : GestureDetector(
                    onTap: () {
                      // ✅ Use Navigator.pop instead of Get.back
                      Navigator.of(context).pop();
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
            // ✅ LOADING STATE
            if (controller.isLoading) {
              return _buildLoadingState(context);
            }

            // ✅ ERROR STATE
            if (controller.hasError) {
              return _buildErrorState(context, controller);
            }

            // ✅ EMPTY CART STATE
            if (controller.isCartEmpty) {
              return EmptyCartWidget();
            }

            // ✅ CART WITH DATA
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CartFoodListWidget(),
                  // PromoCodeWidget(),
                  // FriendInvitationCard(),
                  AdditionalNotesWidget(),
                  GetBuilder<CartController>(
                    id: 'price_summary',
                    builder: (controller) {
                      return PriceSummaryWidget(
                        subtotal: controller.subtotal,
                        deliveryFee: controller.deliveryFee,
                        taxAmount: controller.taxAmount,
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
            if (controller.isCartEmpty || controller.isLoading || controller.hasError) {
              return SizedBox.shrink();
            }

            return Container(
              width: context.wp(100),
              color: AppColor.scaffoldColor,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: widget.isFromBottomNav ? context.hp(12) : 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  button(
                    name: 'Place Order',
                    width: context.wp(100),
                    fontSize: 16,
                    height: 60,
                    fontWeight: FontWeight.w600,
                    borderRadius: BorderRadius.circular(100),
                    onTap: () => Get.find<CartController>().placeOrder(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// ✅ LOADING STATE with Skeletonizer
  Widget _buildLoadingState(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Food item skeleton
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Container(
                  width: context.wp(100),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColor.black.withOpacity(0.03)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                      20.w,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: context.wp(40), height: 16, color: Colors.grey[300]),
                            10.h,
                            Container(width: context.wp(30), height: 14, color: Colors.grey[300]),
                            10.h,
                            Container(width: context.wp(25), height: 16, color: Colors.grey[300]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Price summary skeleton
            Container(
              width: context.wp(100),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              margin: EdgeInsets.only(bottom: 100),
              decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  ...List.generate(
                    4,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(width: context.wp(30), height: 14, color: Colors.grey[300]),
                          Container(width: context.wp(20), height: 14, color: Colors.grey[300]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ ERROR STATE
  Widget _buildErrorState(BuildContext context, CartController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.withOpacity(0.6)),
          20.h,
          text(
            text: 'Oops! Something went wrong',
            size: 24,
            fontWeight: FontWeight.w600,
            color: AppColor.black.withOpacity(0.7),
          ),
          10.h,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: text(
              text: controller.errorMessage,
              size: 14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.5),
              textAlign: TextAlign.center,
            ),
          ),
          40.h,
          button(
            name: 'Retry',
            width: context.wp(60),
            fontSize: 16,
            height: 50,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(100),
            onTap: () => controller.retryFetchCart(),
          ),
        ],
      ),
    );
  }
}
