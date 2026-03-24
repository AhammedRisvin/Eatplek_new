import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/routes/routes.dart';
import '../controller/cart_controller.dart';
import 'widget/add_friend_bottom_sheet.dart';
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
  late ResponsiveHelper responsive;

  @override
  void initState() {
    super.initState();
    responsive = ResponsiveHelper();
  }

  @override
  Widget build(BuildContext context) {
    responsive = ResponsiveHelper();

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: responsive.spacing80,
          centerTitle: widget.isFromBottomNav ? true : false,
          title: Text(
            'Cart',
            style: TextStyle(
              fontSize: responsive.fontSize18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          leading:
              widget.isFromBottomNav
                  ? const SizedBox.shrink()
                  : GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      radius: responsive.spacing25,
                      backgroundColor: Colors.transparent,
                      child: Container(
                        padding: EdgeInsets.all(responsive.spacing16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withOpacity(0.06),
                            width: 1.5,
                          ),
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
              return const EmptyCartWidget();
            }

            // ✅ CART WITH DATA
            return SingleChildScrollView(
              padding: EdgeInsets.all(responsive.spacing20),
              child: Column(
                children: [
                  const CartFoodListWidget(),

                  // ── Friend invitations (below cart items) ──────────────
                  GetBuilder<CartController>(
                    id: 'friend_invitations',
                    builder:
                        (ctrl) => FriendInvitationsSection(
                          invitations: ctrl.friendInvitations,
                          isCartOwner: ctrl.isCartOwner,
                        ),
                  ),

                  PromoCodeWidget(),
                  const AdditionalNotesWidget(),

                  GetBuilder<CartController>(
                    id: 'price_summary',
                    builder: (controller) {
                      final totals = controller.cartModel?.data?.totals;

                      // ── Coupon discount ──────────────────────────────────
                      final apiCouponDiscount =
                          (totals?.couponDiscount ?? 0).toDouble();
                      final effectiveDiscount =
                          apiCouponDiscount > 0
                              ? apiCouponDiscount
                              : controller.promoDiscount;

                      // ── Coupon code label ────────────────────────────────
                      final apiCouponCode =
                          controller.cartModel?.data?.couponCode;
                      final appliedCode =
                          (apiCouponCode != null &&
                                  apiCouponCode.toString().isNotEmpty)
                              ? apiCouponCode.toString()
                              : controller.appliedPromoCode;

                      return PriceSummaryWidget(
                        subtotal: controller.subtotal,
                        deliveryFee: null,
                        taxAmount:
                            totals != null ? (totals.taxAmount ?? 0) : null,
                        packingCharge:
                            totals != null
                                ? (totals.packingChargeTotal ?? 0).toDouble()
                                : null,
                        promoDiscount: effectiveDiscount,
                        appliedPromoCode: appliedCode,
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
            if (controller.isCartEmpty ||
                controller.isLoading ||
                controller.hasError) {
              return const SizedBox.shrink();
            }

            return Container(
              width: responsive.screenWidth,
              color: AppColor.scaffoldColor,
              padding: EdgeInsets.only(
                left: responsive.spacing20,
                right: responsive.spacing20,
                top: responsive.spacing20,
                bottom:
                    widget.isFromBottomNav
                        ? responsive.bottomPadding + 110
                        : responsive.spacing20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Add Friend to Order (cart owner only) ──────────────
                  if (controller.isCartOwner)
                    GestureDetector(
                      onTap: () => AddFriendToCartBottomSheet.show(),
                      child: Container(
                        width: responsive.screenWidth,
                        height: responsive.buttonHeight,
                        margin: EdgeInsets.only(bottom: responsive.spacing12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            responsive.spacing40,
                          ),
                          border: Border.all(
                            color: Get.theme.primaryColor,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_add_alt_1_rounded,
                              size: responsive.spacing20,
                              color: Get.theme.primaryColor,
                            ),
                            SizedBox(width: responsive.spacing8),
                            Text(
                              'Add Friend to Order',
                              style: TextStyle(
                                fontSize: responsive.fontSize16,
                                fontWeight: FontWeight.w600,
                                color: Get.theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Place Order ────────────────────────────────────────
                  button(
                    name: 'Place Order',
                    width: responsive.screenWidth,
                    fontSize: responsive.fontSize16,
                    height: responsive.buttonHeight,
                    fontWeight: FontWeight.w600,
                    borderRadius: BorderRadius.circular(responsive.spacing40),
                    onTap: () => _navigateToOrderConfirmation(controller),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// ✅ Navigate to Order Confirmation with cart data
  void _navigateToOrderConfirmation(CartController cartController) {
    if (!cartController.validateInstructions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartController.instructionsError),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
      return;
    }

    if (cartController.isCartEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add items to cart before placing order'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
      return;
    }

    final vendor = cartController.cartModel?.data?.vendor;
    final totals = cartController.cartModel?.data?.totals;

    // ✅ Resolve effective discount and code from API totals
    final apiCouponDiscount = (totals?.couponDiscount ?? 0).toDouble();
    final effectiveDiscount =
        apiCouponDiscount > 0
            ? apiCouponDiscount
            : cartController.promoDiscount;

    final apiCouponCode = cartController.cartModel?.data?.couponCode;
    final effectiveCode =
        (apiCouponCode != null && apiCouponCode.toString().isNotEmpty)
            ? apiCouponCode.toString()
            : cartController.appliedPromoCode;

    debugPrint('═════════════════════════════════════════');
    debugPrint('🛒 NAVIGATING TO ORDER CONFIRMATION');
    debugPrint('═════════════════════════════════════════');
    debugPrint('📦 Cart Items Count: ${cartController.cartItems.length}');
    debugPrint('🏪 Vendor: ${vendor?.name} | ID: ${vendor?.id}');
    debugPrint('💵 Total: ${cartController.totalAmount}');
    debugPrint('🎟 Coupon: $effectiveCode | Discount: $effectiveDiscount');
    debugPrint('═════════════════════════════════════════');

    Get.toNamed(
      Routes.orderConfirmationView,
      arguments: {
        'cartItems': cartController.cartItems,
        'vendor': vendor,
        'subtotal': cartController.subtotal,
        'taxAmount': cartController.taxAmount,
        'packingCharge': cartController.packingCharge,
        'totalAmount': cartController.totalAmount,
        'instructions': cartController.instructionsController.text.trim(),
        'appliedPromoCode': effectiveCode,
        'promoDiscount': effectiveDiscount,
      },
    );
  }

  /// ✅ LOADING STATE with Skeletonizer
  Widget _buildLoadingState(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.spacing20),
        child: Column(
          children: [
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: responsive.spacing20),
                child: Container(
                  width: responsive.screenWidth,
                  padding: EdgeInsets.all(responsive.spacing20),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(
                      responsive.largeBorderRadius,
                    ),
                    border: Border.all(color: AppColor.black.withOpacity(0.03)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: responsive.spacing80,
                        height: responsive.spacing80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(
                            responsive.smallBorderRadius,
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.spacing20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: responsive.screenWidth * 0.4,
                              height: responsive.spacing16,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: responsive.spacing10),
                            Container(
                              width: responsive.screenWidth * 0.3,
                              height: responsive.spacing14,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: responsive.spacing10),
                            Container(
                              width: responsive.screenWidth * 0.25,
                              height: responsive.spacing16,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: responsive.screenWidth,
              padding: EdgeInsets.symmetric(
                vertical: responsive.spacing20,
                horizontal: responsive.spacing20,
              ),
              margin: EdgeInsets.only(bottom: responsive.spacing100),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(
                  responsive.largeBorderRadius,
                ),
              ),
              child: Column(
                children: [
                  ...List.generate(
                    4,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: responsive.spacing16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: responsive.screenWidth * 0.3,
                            height: responsive.spacing14,
                            color: Colors.grey[300],
                          ),
                          Container(
                            width: responsive.screenWidth * 0.2,
                            height: responsive.spacing14,
                            color: Colors.grey[300],
                          ),
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
          Icon(
            Icons.error_outline,
            size: responsive.spacing80,
            color: Colors.red.withOpacity(0.6),
          ),
          SizedBox(height: responsive.spacing20),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: responsive.fontSize24,
              fontWeight: FontWeight.w600,
              color: AppColor.black.withOpacity(0.7),
            ),
          ),
          SizedBox(height: responsive.spacing10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
            child: Text(
              controller.errorMessage,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: responsive.spacing40),
          button(
            name: 'Retry',
            width: responsive.screenWidth * 0.6,
            fontSize: responsive.fontSize16,
            height: responsive.spacing50,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(responsive.spacing40),
            onTap: () => controller.retryFetchCart(),
          ),
        ],
      ),
    );
  }
}
