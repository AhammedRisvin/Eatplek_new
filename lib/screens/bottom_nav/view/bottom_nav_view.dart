import 'package:eatplek_app/screens/cart/controller/cart_service.dart';
import 'package:eatplek_app/screens/cart/view/cart_view.dart';
import 'package:eatplek_app/screens/home/view/home_view.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
// import '../../offer_view/view/offer_view.dart'; // Coming soon — uncomment when ready
import '../../orders/view/orders_view.dart';
import '../../profile/view/profile_view.dart';
import '../controller/bottom_nav_controller.dart';
import 'widget/custom_painter_bottom.dart';

class BottomNavView extends StatefulWidget {
  const BottomNavView({super.key});

  @override
  State<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView> {
  final controller = Get.find<BottomNavController>();

  List<Widget> bodyList = [
    const HomeView(),
    const OrdersView(),
    // const CartView(isFromBottomNav: true), // index 2
    const CartView(isFromBottomNav: true),
    const ProfileView(),
    // const OfferView(), // Coming soon — uncomment when ready
  ];

  bool _isAssetPath(String icon) => icon.startsWith('assets/');

  Widget _buildSvgIcon(String icon, double size, bool isActive) {
    if (_isAssetPath(icon)) {
      return SvgPicture.asset(icon, width: size, height: size);
    }
    return SvgPicture.string(
      icon,
      width: size,
      height: size,
      colorFilter:
          isActive
              ? ColorFilter.mode(AppColor.appPrimary, BlendMode.srcIn)
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Compact nav height — reduced from 8.5% to 7% of screen height
    final double navHeight = size.height * 0.07;

    // ── Marketplace FAB (coming soon) ──────────────────────────────────────
    // final double fabSize = size.width * 0.15;
    // final double fabPositionBottom = navHeight * 0.45;
    // ──────────────────────────────────────────────────────────────────────

    return GetBuilder(
      id: 'currentIndex',
      init: controller,
      builder: (updater) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(
                  height: context.hp(100),
                  width: context.wp(100),
                  child: bodyList[updater.currentIndex],
                ),
              ),

              /// BOTTOM NAVIGATION
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: size.width,
                  height: navHeight,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background — flat white bar
                      CustomPaint(
                        size: Size(size.width, navHeight),
                        painter: BNBCustomPainter(),
                      ),

                      // ── Marketplace FAB (coming soon) ──────────────────
                      // Positioned(
                      //   bottom: fabPositionBottom,
                      //   left: size.width / 2 - (fabSize / 2),
                      //   child: Container(
                      //     height: fabSize,
                      //     width: fabSize,
                      //     decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       color: AppColor.appPrimary,
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: AppColor.appPrimary.withOpacity(.32),
                      //           blurRadius: 16,
                      //           spreadRadius: 3,
                      //         ),
                      //       ],
                      //     ),
                      //     child: IconButton(
                      //       icon: SvgPicture.string(marketPlaceSvg),
                      //       onPressed: () => controller.setBottomBarIndex(4),
                      //     ),
                      //   ),
                      // ),
                      // ──────────────────────────────────────────────────

                      // Navigation Icons + Labels + Indicators
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            navItem(
                              iconActive: activeHomeSvg,
                              iconInactive: inActiveHomeSvg,
                              label: "Home",
                              index: 0,
                              isActive: updater.currentIndex == 0,
                              screenSize: size,
                            ),
                            navItem(
                              iconActive: activeOrdersSvg,
                              iconInactive: ordersInactiveSvg,
                              label: "Orders",
                              index: 1,
                              isActive: updater.currentIndex == 1,
                              screenSize: size,
                            ),

                            // ── Offer nav item (coming soon) ───────────
                            // navItem(
                            //   iconActive: activeOfferSvg,
                            //   iconInactive: inActiveOfferSvg,
                            //   label: "Offers",
                            //   index: 4,
                            //   isActive: updater.currentIndex == 4,
                            //   screenSize: size,
                            // ),
                            // ────────────────────────────────────────────

                            // ── Cart with badge ──────────────────────────
                            Obx(() {
                              final cartService = Get.find<CartService>();
                              final count = cartService.itemCount.value;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  navItem(
                                    iconActive: activeCartSvg,
                                    iconInactive: inActiveCartSvg,
                                    label: "Cart",
                                    index: 2,
                                    isActive: updater.currentIndex == 2,
                                    screenSize: size,
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          count > 99 ? '99+' : '$count',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            height: 1,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),

                            navItem(
                              iconActive: activeProfileSvg,
                              iconInactive: inActiveProfileSvg,
                              label: "Profile",
                              index: 3,
                              isActive: updater.currentIndex == 3,
                              screenSize: size,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// COMMON WIDGET FOR NAV ITEMS WITH INDICATOR AT TOP
  Widget navItem({
    required String iconActive,
    required String iconInactive,
    required String label,
    required int index,
    required bool isActive,
    required Size screenSize,
  }) {
    final iconSize = screenSize.width * 0.055;
    final labelFontSize = screenSize.width * 0.028;
    final indicatorHeight = screenSize.height * 0.003;
    final indicatorWidth = screenSize.width * 0.07;

    return GestureDetector(
      onTap: () => controller.setBottomBarIndex(index),
      child: SizedBox(
        width: screenSize.width * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top active indicator
            if (isActive)
              Padding(
                padding: EdgeInsets.only(bottom: screenSize.height * 0.005),
                child: Container(
                  width: indicatorWidth,
                  height: indicatorHeight,
                  decoration: BoxDecoration(
                    color: AppColor.appPrimary,
                    borderRadius: BorderRadius.circular(
                      screenSize.height * 0.002,
                    ),
                  ),
                ),
              )
            else
              SizedBox(height: screenSize.height * 0.005 + indicatorHeight),
            _buildSvgIcon(
              isActive ? iconActive : iconInactive,
              iconSize,
              isActive,
            ),
            SizedBox(height: screenSize.height * 0.003),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                color:
                    isActive
                        ? AppColor.appPrimary
                        : AppColor.black.withOpacity(0.6),
                fontFamily: GoogleFonts.urbanist().fontFamily,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
