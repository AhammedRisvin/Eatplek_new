import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/responsive_helper.dart';

class ResponsiveOrderAcceptedSheet extends StatefulWidget {
  final dynamic selectedPaymentMethod;

  const ResponsiveOrderAcceptedSheet({super.key, required this.selectedPaymentMethod});

  @override
  State<ResponsiveOrderAcceptedSheet> createState() => _ResponsiveOrderAcceptedSheetState();
}

class _ResponsiveOrderAcceptedSheetState extends State<ResponsiveOrderAcceptedSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Setup scale and opacity animation for success state
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.bottomSheetPadding,
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.extraLargeBorderRadius)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Drag indicator
            Align(
              alignment: Alignment.center,
              child: Container(
                width: responsive.spacing120,
                height: responsive.spacing4,
                margin: EdgeInsets.only(bottom: responsive.spacing10),
                decoration: BoxDecoration(
                  color: const Color(0XFFD9D9D9),
                  borderRadius: BorderRadius.circular(responsive.extraLargeBorderRadius),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing30),

            // ✅ Payment method image
            ScaleTransition(
              scale: _scaleAnimation,
              child: OpacityTransition(
                opacity: _opacityAnimation,
                child: image(
                  url: widget.selectedPaymentMethod['imageUrl'],
                  width: responsive.iconSizeXXL,
                  height: responsive.iconSizeXXL,
                  borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing30),

            // ✅ Success checkmark icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: OpacityTransition(
                opacity: _opacityAnimation,
                child: Container(
                  width: responsive.spacing80,
                  height: responsive.spacing80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Icon(Icons.check_circle_rounded, color: Colors.green, size: responsive.iconSizeLarge),
                  ),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing30),

            // ✅ Title
            OpacityTransition(
              opacity: _opacityAnimation,
              child: text(
                text: 'Order Accepted!',
                size: responsive.fontSize22,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: responsive.spacing10),

            // ✅ Description
            OpacityTransition(
              opacity: _opacityAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing12),
                child: text(
                  text: 'The restaurant has accepted your order. We are preparing your food now.',
                  size: responsive.fontSize16,
                  fontWeight: FontWeight.w400,
                  color: AppColor.black.withOpacity(0.4),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: responsive.spacing30),

            // ✅ Success info box
            OpacityTransition(
              opacity: _opacityAnimation,
              child: Container(
                width: responsive.widthPercent(100),
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing14, vertical: responsive.spacing14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: responsive.iconSizeSmall, color: Colors.green),
                    SizedBox(width: responsive.spacing12),
                    Expanded(
                      child: text(
                        text: 'Your order will be ready shortly. Thank you for your order!',
                        size: responsive.fontSize12,
                        fontWeight: FontWeight.w400,
                        color: Colors.green.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: responsive.spacing30),
          ],
        ),
      ),
    );
  }
}

/// ✅ Custom OpacityTransition widget
class OpacityTransition extends AnimatedWidget {
  final Widget child;
  final Animation<double> opacity;

  const OpacityTransition({super.key, required this.opacity, required this.child}) : super(listenable: opacity);

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: opacity.value, child: child);
  }
}
