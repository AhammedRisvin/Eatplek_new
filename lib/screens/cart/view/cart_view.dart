import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/routes/routes.dart';
import '../../bottom_nav/controller/bottom_nav_controller.dart';
import '../controller/cart_controller.dart';
import '../controller/cart_service.dart';
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
  final ResponsiveHelper responsive = ResponsiveHelper();

  @override
  void initState() {
    super.initState();

    if (widget.isFromBottomNav) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final navCtrl = Get.find<BottomNavController>();
          if (navCtrl.currentIndex == 3) {
            Get.find<CartService>().onCartViewEntered();
            if (Get.isRegistered<CartController>()) {
              Get.find<CartController>().fetchCartData();
            }
          }
        } catch (_) {}
      });
    } else {
      Get.find<CartService>().onCartViewEntered();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<CartController>()) {
          Get.find<CartController>().fetchCartData();
        }
      });
    }
  }

  @override
  void dispose() {
    Get.find<CartService>().onCartViewExited();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColor.scaffoldColor,
        appBar: _buildAppBar(),
        body: GetBuilder<CartController>(
          id: 'empty_cart',
          builder: (controller) {
            if (controller.isLoading) return _buildLoadingState();
            if (controller.hasError) return _buildErrorState(controller);
            if (controller.isCartEmpty) return const EmptyCartWidget();

            return SingleChildScrollView(
              padding: EdgeInsets.all(responsive.spacing20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const CartFoodListWidget(),

                  GetBuilder<CartController>(
                    id: 'friend_invitations',
                    builder:
                        (ctrl) => FriendInvitationsSection(
                          invitations: ctrl.friendInvitations,
                          isCartOwner: ctrl.isCartOwner,
                        ),
                  ),

                  const PromoCodeWidget(),
                  const AdditionalNotesWidget(),

                  GetBuilder<CartController>(
                    id: 'price_summary',
                    builder: (ctrl) {
                      final totals = ctrl.cartModel?.data?.totals;
                      final apiDiscount =
                          (totals?.couponDiscount ?? 0).toDouble();
                      final effectiveDiscount =
                          apiDiscount > 0 ? apiDiscount : ctrl.promoDiscount;
                      final apiCode = ctrl.cartModel?.data?.couponCode;
                      final appliedCode =
                          (apiCode != null && apiCode.toString().isNotEmpty)
                              ? apiCode.toString()
                              : ctrl.appliedPromoCode;

                      return PriceSummaryWidget(
                        subtotal: ctrl.subtotal,
                        deliveryFee: null,
                        taxAmount:
                            totals != null ? (totals.taxAmount ?? 0) : null,
                        packingCharge:
                            totals != null
                                ? (totals.packingChargeTotal ?? 0).toDouble()
                                : null,
                        promoDiscount: effectiveDiscount,
                        appliedPromoCode: appliedCode,
                        totalAmount: ctrl.totalAmount,
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
            return _buildBottomBar(controller);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leadingWidth: responsive.spacing80,
      centerTitle: widget.isFromBottomNav,
      title: Text(
        'Cart',
        style: TextStyle(
          fontSize: responsive.fontSize18,
          fontWeight: FontWeight.w700,
          color: AppColor.black,
        ),
      ),
      leading:
          widget.isFromBottomNav
              ? const SizedBox.shrink()
              : GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Center(
                  child: Container(
                    width: responsive.spacing40,
                    height: responsive.spacing40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.white,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.08),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(child: SvgPicture.string(arrowBack2)),
                  ),
                ),
              ),
    );
  }

  Widget _buildBottomBar(CartController controller) {
    return Container(
      color: AppColor.scaffoldColor,
      padding: EdgeInsets.only(
        left: responsive.spacing20,
        right: responsive.spacing20,
        top: responsive.spacing16,
        bottom:
            widget.isFromBottomNav
                ? responsive.bottomPadding + responsive.spacing10
                : responsive.spacing20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.isCartOwner)
            GestureDetector(
                  onTap: () => AddFriendToCartBottomSheet.show(),
                  child: Container(
                    width: double.infinity,
                    height: responsive.buttonHeight,
                    margin: EdgeInsets.only(bottom: responsive.spacing12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsive.spacing40),
                      border: Border.all(
                        color: AppColor.appPrimary,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          size: responsive.spacing20,
                          color: AppColor.appPrimary,
                        ),
                        SizedBox(width: responsive.spacing8),
                        Text(
                          'Add Friend to Order',
                          style: TextStyle(
                            fontSize: responsive.fontSize15,
                            fontWeight: FontWeight.w600,
                            color: AppColor.appPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fade(duration: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms),

          button(
                name: 'Place Order',
                width: double.infinity,
                fontSize: responsive.fontSize16,
                height: responsive.buttonHeight,
                fontWeight: FontWeight.w700,
                borderRadius: BorderRadius.circular(responsive.spacing40),
                onTap: () => _navigateToConfirmation(controller),
              )
              .animate()
              .fade(duration: 300.ms, delay: 50.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 50.ms),
        ],
      ),
    );
  }

  void _navigateToConfirmation(CartController cartController) {
    if (!cartController.validateInstructions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartController.instructionsError),
          backgroundColor: Colors.red.withOpacity(0.85),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
          ),
        ),
      );
      return;
    }
    if (cartController.isCartEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add items to cart before placing order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final vendor = cartController.cartModel?.data?.vendor;
    final totals = cartController.cartModel?.data?.totals;
    final apiDiscount = (totals?.couponDiscount ?? 0).toDouble();
    final effectiveDiscount =
        apiDiscount > 0 ? apiDiscount : cartController.promoDiscount;
    final apiCode = cartController.cartModel?.data?.couponCode;
    final effectiveCode =
        (apiCode != null && apiCode.toString().isNotEmpty)
            ? apiCode.toString()
            : cartController.appliedPromoCode;

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

  Widget _buildLoadingState() {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        baseColor: Color(0xFFEEEEEE),
        highlightColor: Color(0xFFF8F8F8),
        duration: Duration(milliseconds: 1200),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.spacing20),
        child: Column(
          children: List.generate(
            3,
            (_) => Container(
              width: double.infinity,
              height: responsive.spacing100,
              margin: EdgeInsets.only(bottom: responsive.spacing16),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(
                  responsive.largeBorderRadius,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(CartController controller) {
    return errorState(
      message: controller.errorMessage,
      onRetry: controller.retryFetchCart,
    );
  }
}
