// ignore_for_file: unnecessary_underscores

import 'package:eatplek_app/core/util/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controller/coupons_controller.dart';
import '../model/coupons_model.dart';
import 'widget/coupon_bg_custom_paint.dart';

class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  @override
  void initState() {
    super.initState();
    // fenix: true keeps the instance alive across navigations
    // and reuses it if already registered — onInit only fires once
    if (!Get.isRegistered<CouponsController>()) {
      Get.put(CouponsController(), permanent: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CouponsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.scaffoldColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Coupons',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(CouponsController controller) {
    if (controller.isLoading) return _buildSkeletonLoader();
    if (controller.hasError) return _buildErrorState(controller);
    if (controller.coupons.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio:
            ((MediaQuery.of(context).size.width - 44) / 2) /
            (MediaQuery.of(context).size.height * 0.30),
      ),
      itemCount: controller.coupons.length,
      itemBuilder: (context, index) {
        final coupon = controller.coupons[index];
        return _CouponCard(
          coupon: coupon,
          isApplying: controller.applyingCode == coupon.code,
          onApply: () {
            if (controller.applyingCode != null) return;
            controller.applyCode(
              coupon.code ?? '',
              onError: (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(err),
                    backgroundColor: Colors.red.withOpacity(0.85),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return Skeletonizer(
      enabled: true,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio:
              ((MediaQuery.of(context).size.width - 44) / 2) /
              (MediaQuery.of(context).size.height * 0.30),
        ),
        itemCount: 4,
        itemBuilder: (_, __) => const _SkeletonCouponCard(),
      ),
    );
  }

  Widget _buildErrorState(CouponsController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: Colors.red.withOpacity(0.55),
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controller.retryfetch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CC06F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.discount_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No Coupons Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for exciting offers!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOW THE PAINTER WORKS (from reading the path coordinates):
//
//  • The bumps are at y = -0.001 to y = 0.0568  → they PROTRUDE UPWARD above y=0
//  • The perforation dashes are at y = 0.494–0.505 → exactly the MIDPOINT
//  • The full shape goes to y = 0.998 at the bottom
//
//  CORRECT APPROACH:
//  Give the painter the FULL card height. Its midpoint (y=0.5) becomes the
//  green/white divider. The bumps protrude above — so the card needs a top
//  margin equal to (bumpHeight = painterH * 0.058) so bumps are visible.
//  We do NOT clip the top. We DO clip left/right/bottom via ClipRRect.
//
//  Content inside green: starts below the bump zone (below y=0.06 of painter).
// ─────────────────────────────────────────────────────────────────────────────
class _CouponCard extends StatelessWidget {
  final CouponData coupon;
  final VoidCallback onApply;
  final bool isApplying;

  const _CouponCard({
    required this.coupon,
    required this.onApply,
    this.isApplying = false,
  });

  // Bump height as fraction of total painter height
  static const double _bumpFraction = 0.058;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardW = constraints.maxWidth;
        final double cardH = constraints.maxHeight;

        // The painter is given the full card height.
        // Bump protrudes above by: cardH * _bumpFraction
        // We shift the painter DOWN by that amount so bumps sit at card top edge.
        // The card itself has top margin = bumpH so the bumps don't get clipped.
        final double bumpH = cardH * _bumpFraction;

        // Green section ends at painter's midpoint = cardH * 0.5
        // But painter is shifted down by bumpH, so green ends at:
        // bumpH + cardH * 0.5 from the top of the Stack
        final double greenEndY = bumpH + cardH * 0.5;

        // Safe content start inside green (below bump zone)
        final double contentStartY = bumpH + cardH * 0.06;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // ── White card base (full size, rounded, shadow) ───────────────
            Positioned.fill(
              top: bumpH, // card visual starts below bump zone
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),

            // ── RPSCustomPainter: full card height, shifted down by bumpH ──
            // Clip sides & bottom but NOT top (bumps protrude above)
            Positioned(
              top: 0, // painter starts at 0 so bumps show above bumpH
              left: 0,
              right: 0,
              height: cardH,
              child: ClipRect(
                clipper: _BottomSidesClipper(topInset: bumpH),
                child: CustomPaint(
                  painter: RPSCustomPainter(),
                  size: Size(cardW, cardH),
                ),
              ),
            ),

            // ── Green content: white circle icon + discount % + code name ──
            Positioned(
              top: contentStartY,
              left: 12,
              right: 12,
              height: greenEndY - contentStartY - 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Row: white circle icon + discount text
                  Row(
                    children: [
                      // White bg circle icon
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.confirmation_number_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Discount % / amount
                      Text(
                        coupon.discountValue != null
                            ? coupon.discountType == 'percentage'
                                ? '${coupon.discountValue}%'
                                : '₹${coupon.discountValue}'
                            : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Big bold coupon code / title
                  Text(
                    coupon.code ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── White bottom content: description + divider + Apply Code ───
            Positioned(
              top: greenEndY - 15,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (coupon.description != null &&
                          coupon.description!.isNotEmpty)
                        Expanded(
                          child: Text(
                            coupon.description!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black.withOpacity(0.55),
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        const Spacer(),
                      Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: isApplying ? null : onApply,
                        child: Center(
                          child:
                              isApplying
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF3CC06F),
                                    ),
                                  )
                                  : const Text(
                                    'Apply Code',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Clips rect but leaves the top open (so bumps protrude above)
class _BottomSidesClipper extends CustomClipper<Rect> {
  final double topInset;
  const _BottomSidesClipper({required this.topInset});

  @override
  Rect getClip(Size size) {
    // Allow painting from topInset upward (bumps) but clip sides
    return Rect.fromLTWH(0, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(_BottomSidesClipper old) => old.topInset != topInset;
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton placeholder
// ─────────────────────────────────────────────────────────────────────────────
class _SkeletonCouponCard extends StatelessWidget {
  const _SkeletonCouponCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bump space
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 55,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 45,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 10,
                          width: 80,
                          color: Colors.grey[300],
                        ),
                        const Spacer(),
                        Container(
                          height: 12,
                          width: 70,
                          color: Colors.grey[300],
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
    );
  }
}
