import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/responsive_helper.dart';

class ResponsiveWaitingFormConfirmationSheet extends StatefulWidget {
  const ResponsiveWaitingFormConfirmationSheet({super.key});

  @override
  State<ResponsiveWaitingFormConfirmationSheet> createState() =>
      _ResponsiveWaitingFormConfirmationSheetState();
}

class _ResponsiveWaitingFormConfirmationSheetState
    extends State<ResponsiveWaitingFormConfirmationSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Setup pulsing animation for the loading indicator
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.extraLargeBorderRadius),
        ),
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
                  borderRadius: BorderRadius.circular(
                    responsive.extraLargeBorderRadius,
                  ),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing30),

            // ✅ Animated pulsing indicator
            ScaleTransition(
              scale: _scaleAnimation,
              child: OpacityTransition(
                opacity: _opacityAnimation,
                child: Container(
                  width: responsive.spacing100,
                  height: responsive.spacing100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.appPrimary.withOpacity(0.1),
                    border: Border.all(
                      color: AppColor.appPrimary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: responsive.spacing60,
                      height: responsive.spacing60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.appPrimary.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.hourglass_bottom_rounded,
                          color: AppColor.appPrimary,
                          size: responsive.iconSizeLarge,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing40),

            // ✅ Title
            text(
              text: 'Waiting for Confirmation...',
              size: responsive.fontSize22,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing12),

            // ✅ Description
            Container(
              padding: EdgeInsets.symmetric(horizontal: responsive.spacing12),
              child: text(
                text:
                    'Please wait while the restaurant confirms your order. This usually takes 1-2 minutes.',
                size: responsive.fontSize14,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.6),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: responsive.spacing20),

            // ✅ Progress indicator with dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProgressDot(responsive, 0),
                SizedBox(width: responsive.spacing8),
                _buildProgressDot(responsive, 1),
                SizedBox(width: responsive.spacing8),
                _buildProgressDot(responsive, 2),
              ],
            ),
            SizedBox(height: responsive.spacing30),

            // ✅ Info box
            Container(
              width: responsive.widthPercent(100),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.spacing14,
                vertical: responsive.spacing14,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  responsive.inputBorderRadius,
                ),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: responsive.iconSizeSmall,
                    color: Colors.blue,
                  ),
                  SizedBox(width: responsive.spacing12),
                  Expanded(
                    child: text(
                      text:
                          'Do not close this screen. Your order is being processed.',
                      size: responsive.fontSize12,
                      fontWeight: FontWeight.w400,
                      color: Colors.blue.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: responsive.spacing30),
          ],
        ),
      ),
    );
  }

  /// ✅ Build animated progress dots
  Widget _buildProgressDot(ResponsiveHelper responsive, int index) {
    // ✅ FIX: Corrected Interval values to stay within 0.0-1.0 range
    // OLD (broken): Interval(index * 0.3, 0.6 + (index * 0.3), ...)
    // When index=2: start=0.6, end=1.2 ❌ (exceeds 1.0)
    //
    // NEW (fixed): Interval(index * 0.25, 0.5 + (index * 0.25), ...)
    // When index=0: start=0.0, end=0.5 ✅
    // When index=1: start=0.25, end=0.75 ✅
    // When index=2: start=0.5, end=1.0 ✅

    return ScaleTransition(
      scale: Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.25,
            0.5 + (index * 0.25),
            curve: Curves.easeInOut,
          ),
        ),
      ),
      child: Container(
        width: responsive.spacing10,
        height: responsive.spacing10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.appPrimary,
        ),
      ),
    );
  }
}

/// ✅ Custom OpacityTransition widget
class OpacityTransition extends AnimatedWidget {
  final Widget child;
  final Animation<double> opacity;

  const OpacityTransition({
    super.key,
    required this.opacity,
    required this.child,
  }) : super(listenable: opacity);

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: opacity.value, child: child);
  }
}
