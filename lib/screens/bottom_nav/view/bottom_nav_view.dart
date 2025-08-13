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
              Positioned(
                bottom: 0,
                left: 0,
                child: SizedBox(
                  width: size.width,
                  height: 80,
                  child: Stack(
                    children: [
                      CustomPaint(size: Size(size.width, 90), painter: BNBCustomPainter()),
                      Center(
                        heightFactor: 0.68,
                        child: FloatingActionButton(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: AppColor.appPrimary),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          backgroundColor: AppColor.appPrimary,
                          elevation: 0.1,
                          onPressed: () {
                            controller.setBottomBarIndex(4);
                          },
                          child: SvgPicture.string(marketPlaceSvg),
                        ),
                      ),
                      SizedBox(
                        width: size.width,
                        height: 90,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {
                                controller.setBottomBarIndex(0);
                              },
                              icon: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.string(updater.currentIndex == 0 ? activeHomeSvg : inActiveHomeSvg),
                                  pointFiveSpacer(),
                                  commonText(
                                    "Home",
                                    updater.currentIndex == 0 ? AppColor.appPrimary : AppColor.lightBlue,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                controller.setBottomBarIndex(1);
                              },
                              icon: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.string(
                                    updater.currentIndex == 1 ? activeCategorySvg : inActiveCategorySvg,
                                  ),
                                  pointFiveSpacer(),
                                  commonText(
                                    "Categories",
                                    updater.currentIndex == 1 ? AppColor.appPrimary : AppColor.lightBlue,
                                  ),
                                ],
                              ),
                            ),
                            Container(width: size.width * 0.20),
                            IconButton(
                              onPressed: () {
                                controller.setBottomBarIndex(2);
                              },
                              icon: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.string(updater.currentIndex == 2 ? activeCartSvg : inActiveCartSvg),
                                  pointFiveSpacer(),
                                  commonText(
                                    "Cart",
                                    updater.currentIndex == 2 ? AppColor.appPrimary : AppColor.lightBlue,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                controller.setBottomBarIndex(3);
                              },
                              icon: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.string(updater.currentIndex == 3 ? wishlistIconSvg : heartIcon),
                                  pointFiveSpacer(),
                                  commonText(
                                    "Wishlist",
                                    updater.currentIndex == 3 ? AppColor.appPrimary : AppColor.lightBlue,
                                  ),
                                ],
                              ),
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

  SizedBox pointFiveSpacer() => SizedBox(width: 5);

  Text commonText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: GoogleFonts.urbanist().fontFamily,
        color: color,
      ),
    );
  }
}
