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
import '../../offer_view/view/offer_view.dart';
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
    const CartView(isFromBottomNav: true),
    const ProfileView(),
    const OfferView(),
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double navHeight = size.height * 0.085; // 8.5% of screen height
    final double fabSize = size.width * 0.15; // 15% of screen width
    final double fabPositionBottom = navHeight * 0.45;

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
                child: SizedBox(height: context.hp(100), width: context.wp(100), child: bodyList[updater.currentIndex]),
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
                        offset: const Offset(0, -4), // Shadow only at top
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background Painter
                      CustomPaint(size: Size(size.width, navHeight), painter: BNBCustomPainter()),

                      // Center Floating Button
                      Positioned(
                        bottom: fabPositionBottom,
                        left: size.width / 2 - (fabSize / 2),
                        child: Container(
                          height: fabSize,
                          width: fabSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.appPrimary,
                            boxShadow: [
                              BoxShadow(color: AppColor.appPrimary.withOpacity(.32), blurRadius: 16, spreadRadius: 3),
                            ],
                          ),
                          child: IconButton(
                            icon: SvgPicture.string(marketPlaceSvg),
                            onPressed: () {
                              controller.setBottomBarIndex(4);
                            },
                          ),
                        ),
                      ),

                      // Navigation Icons + Labels + Indicators
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SizedBox(
                          height: navHeight * 0.95,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                iconActive: activeCategorySvg,
                                iconInactive: inActiveCategorySvg,
                                label: "Orders",
                                index: 1,
                                isActive: updater.currentIndex == 1,
                                screenSize: size,
                              ),

                              SizedBox(width: fabSize * 1.1), // FAB space

                              navItem(
                                iconActive: activeCartSvg,
                                iconInactive: inActiveCartSvg,
                                label: "Cart",
                                index: 2,
                                isActive: updater.currentIndex == 2,
                                screenSize: size,
                              ),
                              navItem(
                                iconActive: wishlistIconSvg,
                                iconInactive: heartIcon,
                                label: "Profile",
                                index: 3,
                                isActive: updater.currentIndex == 3,
                                screenSize: size,
                              ),
                            ],
                          ),
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
    final iconSize = screenSize.width * 0.055; // Responsive icon size
    final labelFontSize = screenSize.width * 0.032; // Responsive font size
    final indicatorHeight = screenSize.height * 0.004; // Responsive indicator height
    final indicatorWidth = screenSize.width * 0.08; // Responsive indicator width

    return GestureDetector(
      onTap: () => controller.setBottomBarIndex(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Blue indicator at TOP of active icon
          if (isActive)
            Padding(
              padding: EdgeInsets.only(bottom: screenSize.height * 0.006),
              child: Container(
                width: indicatorWidth,
                height: indicatorHeight,
                decoration: BoxDecoration(
                  color: AppColor.appPrimary,
                  borderRadius: BorderRadius.circular(screenSize.height * 0.002),
                ),
              ),
            ),
          SvgPicture.string(isActive ? iconActive : iconInactive, width: iconSize, height: iconSize),
          SizedBox(height: screenSize.height * 0.004),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: isActive ? AppColor.appPrimary : AppColor.lightBlue,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
