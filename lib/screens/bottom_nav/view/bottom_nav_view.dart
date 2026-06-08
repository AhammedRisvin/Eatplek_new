import 'package:eatplek_app/screens/cart/controller/cart_service.dart';
import 'package:eatplek_app/screens/cart/view/cart_view.dart';
import 'package:eatplek_app/screens/home/view/home_view.dart';
import 'package:eatplek_app/screens/offer_view/view/offer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../orders/view/orders_view.dart';
import '../../profile/view/profile_view.dart';
import '../controller/bottom_nav_controller.dart';
import 'widget/custom_painter_bottom.dart';

class BottomNavView extends StatefulWidget {
  const BottomNavView({super.key});

  @override
  State<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<BottomNavController>();

  // Keep all pages alive — prevents re-build on tab switch
  final List<Widget> _pages = const [
    HomeView(),
    OrdersView(),
    OfferView(),
    CartView(isFromBottomNav: true),
    ProfileView(),
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
              ? const ColorFilter.mode(AppColor.appPrimary, BlendMode.srcIn)
              : const ColorFilter.mode(Color(0xFF9DB2CE), BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double navHeight = size.height * 0.075;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return GetBuilder<BottomNavController>(
      id: 'currentIndex',
      init: controller,
      builder: (ctrl) {
        return Scaffold(
          // IndexedStack keeps all pages mounted — no rebuild on tab switch
          body: IndexedStack(index: ctrl.currentIndex, children: _pages),

          bottomNavigationBar: _buildBottomNav(
            context,
            ctrl,
            size,
            navHeight,
            bottomPadding,
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    BottomNavController ctrl,
    Size size,
    double navHeight,
    double bottomPadding,
  ) {
    final bumpHeight = navHeight * 0.42;
    final totalHeight = navHeight + bottomPadding;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(painter: BNBCustomPainter()),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: navHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: _navItem(
                        iconActive: activeHomeSvg,
                        iconInactive: inActiveHomeSvg,
                        label: 'Home',
                        index: 0,
                        isActive: ctrl.currentIndex == 0,
                        size: size,
                        navHeight: navHeight,
                        ctrl: ctrl,
                      ),
                    ),
                    Expanded(
                      child: _navItem(
                        iconActive: activeOrdersSvg,
                        iconInactive: ordersInactiveSvg,
                        label: 'Orders',
                        index: 1,
                        isActive: ctrl.currentIndex == 1,
                        size: size,
                        navHeight: navHeight,
                        ctrl: ctrl,
                      ),
                    ),
                    Expanded(
                      child: _offerNavItem(
                        isActive: ctrl.currentIndex == 2,
                        size: size,
                        navHeight: navHeight,
                        ctrl: ctrl,
                      ),
                    ),
                    Expanded(
                      child: _cartNavItem(
                        isActive: ctrl.currentIndex == 3,
                        size: size,
                        navHeight: navHeight,
                        ctrl: ctrl,
                      ),
                    ),
                    Expanded(
                      child: _navItem(
                        iconActive: activeProfileSvg,
                        iconInactive: inActiveProfileSvg,
                        label: 'Profile',
                        index: 4,
                        isActive: ctrl.currentIndex == 4,
                        size: size,
                        navHeight: navHeight,
                        ctrl: ctrl,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -bumpHeight * 0.9,
            child: _offerFab(
              isActive: ctrl.currentIndex == 2,
              size: size,
              ctrl: ctrl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _offerFab({
    required bool isActive,
    required Size size,
    required BottomNavController ctrl,
  }) {
    final fabSize = size.width * 0.14;
    final iconSize = size.width * 0.058;

    return GestureDetector(
      onTap: () => ctrl.setBottomBarIndex(2),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        width: fabSize,
        height: fabSize,
        decoration: BoxDecoration(
          color: AppColor.appPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.appPrimary.withOpacity(0.32),
              blurRadius: 22,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.percent_rounded,
          color: AppColor.white,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _offerNavItem({
    required bool isActive,
    required Size size,
    required double navHeight,
    required BottomNavController ctrl,
  }) {
    final double labelSize = size.width * 0.028;

    return GestureDetector(
      onTap: () => ctrl.setBottomBarIndex(2),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: navHeight,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: navHeight * 0.16),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: labelSize,
                fontFamily: GoogleFonts.urbanist().fontFamily,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColor.appPrimary : const Color(0xFF9DB2CE),
              ),
              child: const Text('Offers'),
            ),
          ),
        ),
      ),
    );
  }

  // ── Standard nav item ────────────────────────────────────────────────────
  Widget _navItem({
    required String iconActive,
    required String iconInactive,
    required String label,
    required int index,
    required bool isActive,
    required Size size,
    required double navHeight,
    required BottomNavController ctrl,
  }) {
    final double iconSize = size.width * 0.057;
    final double labelSize = size.width * 0.028;

    return GestureDetector(
      onTap: () => ctrl.setBottomBarIndex(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: navHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active indicator dot at top
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: isActive ? 20 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            // Icon with scale animation on tap
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: _buildSvgIcon(
                isActive ? iconActive : iconInactive,
                iconSize,
                isActive,
              ),
            ),

            const SizedBox(height: 4),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: labelSize,
                fontFamily: GoogleFonts.urbanist().fontFamily,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColor.appPrimary : const Color(0xFF9DB2CE),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cart nav item with badge ─────────────────────────────────────────────
  Widget _cartNavItem({
    required bool isActive,
    required Size size,
    required double navHeight,
    required BottomNavController ctrl,
  }) {
    final double iconSize = size.width * 0.057;
    final double labelSize = size.width * 0.028;

    return GestureDetector(
      onTap: () => ctrl.setBottomBarIndex(3),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: navHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: isActive ? 20 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            // Cart icon + badge
            Obx(() {
              final cartService = Get.find<CartService>();
              final count = cartService.itemCount.value;

              return AnimatedScale(
                scale: isActive ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildSvgIcon(
                      isActive ? activeCartSvg : inActiveCartSvg,
                      iconSize,
                      isActive,
                    ),
                    if (count > 0)
                      Positioned(top: -5, right: -7, child: _buildBadge(count)),
                  ],
                ),
              );
            }),

            const SizedBox(height: 4),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: labelSize,
                fontFamily: GoogleFonts.urbanist().fontFamily,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColor.appPrimary : const Color(0xFF9DB2CE),
              ),
              child: const Text('Cart'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cart badge ───────────────────────────────────────────────────────────
  Widget _buildBadge(int count) {
    return AnimatedScale(
          scale: count > 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.all(3),
            constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
            decoration: BoxDecoration(
              color: AppColor.redColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColor.redColor.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
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
        )
        .animate(target: count > 0 ? 1 : 0)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 250.ms,
          curve: Curves.easeOutBack,
        );
  }
}
