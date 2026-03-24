import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/order_confirmation_controller.dart';
import '../../service/phonepay_service.dart';

class PaymentResultBottomSheet extends StatelessWidget {
  final PhonePePaymentResult result;
  final OrderConfirmationController controller;

  const PaymentResultBottomSheet({
    super.key,
    required this.result,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        width: responsive.widthPercent(100),
        padding: responsive.bottomSheetPadding,
        decoration: BoxDecoration(
          color: AppColor.scaffoldColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(responsive.extraLargeBorderRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──
            Container(
              width: responsive.spacing120,
              height: responsive.spacing4,
              margin: EdgeInsets.only(bottom: responsive.spacing16),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(
                  responsive.extraLargeBorderRadius,
                ),
              ),
            ),

            SizedBox(height: responsive.spacing8),

            // ── Status icon ──
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _statusColor.withOpacity(0.12),
              ),
              child: Icon(_statusIcon, size: 42, color: _statusColor),
            ),

            SizedBox(height: responsive.spacing20),

            // ── Title ──
            text(
              text: _titleText,
              size: responsive.fontSize20,
              fontWeight: FontWeight.w700,
              color: _statusColor,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: responsive.spacing8),

            // ── Subtitle ──
            text(
              text: _subtitleText,
              size: responsive.fontSize14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
              textAlign: TextAlign.center,
            ),

            // ── Transaction reference (success + pending only) ──
            if (result.merchantOrderId != null &&
                result.merchantOrderId!.isNotEmpty) ...[
              SizedBox(height: responsive.spacing16),
              Container(
                width: responsive.widthPercent(100),
                padding: EdgeInsets.symmetric(
                  vertical: responsive.spacing12,
                  horizontal: responsive.spacing16,
                ),
                decoration: BoxDecoration(
                  color: AppColor.scaffoldColor,
                  borderRadius: BorderRadius.circular(
                    responsive.inputBorderRadius,
                  ),
                  border: Border.all(color: AppColor.black.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    text(
                      text: 'Order Reference',
                      size: responsive.fontSize12,
                      fontWeight: FontWeight.w400,
                      color: AppColor.black.withOpacity(0.5),
                    ),
                    SizedBox(height: responsive.spacing4),
                    text(
                      text: result.merchantOrderId!,
                      size: responsive.fontSize13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: responsive.spacing24),

            // ── Primary CTA ──
            button(
              name: _primaryButtonText,
              width: responsive.widthPercent(100),
              height: responsive.formFieldHeight,
              fontSize: responsive.fontSize16,
              fontWeight: FontWeight.w600,
              borderRadius: BorderRadius.circular(
                responsive.extraLargeBorderRadius,
              ),
              color: result.isSuccess ? AppColor.appPrimary : _statusColor,
              onTap: () => _onPrimaryTap(),
            ),

            SizedBox(height: responsive.spacing12),

            // ── Secondary CTA — failure and pending only ──
            if (!result.isSuccess) ...[
              GestureDetector(
                onTap: () => _onSecondaryTap(),
                child: Container(
                  width: responsive.widthPercent(100),
                  height: responsive.formFieldHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      responsive.extraLargeBorderRadius,
                    ),
                    border: Border.all(
                      color: AppColor.appPrimary,
                      width: responsive.borderWidthMedium,
                    ),
                  ),
                  child: text(
                    text: 'Go to My Orders',
                    size: responsive.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.appPrimary,
                  ),
                ),
              ),
              SizedBox(height: responsive.spacing12),
            ],

            // ── Security badge ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 13,
                  color: AppColor.black.withOpacity(0.35),
                ),
                SizedBox(width: responsive.spacing4),
                text(
                  text: 'Secured by PhonePe',
                  size: responsive.fontSize12,
                  fontWeight: FontWeight.w400,
                  color: AppColor.black.withOpacity(0.35),
                ),
              ],
            ),

            SizedBox(height: responsive.spacing8),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  Color get _statusColor {
    if (result.isSuccess) return Colors.green;
    if (result.isPending) return Colors.orange;
    return Colors.red;
  }

  IconData get _statusIcon {
    if (result.isSuccess) return Icons.check_circle_rounded;
    if (result.isPending) return Icons.access_time_rounded;
    return Icons.cancel_rounded;
  }

  String get _titleText {
    if (result.isSuccess) return 'Payment Successful!';
    if (result.isPending) return 'Payment Pending';
    return 'Payment Failed';
  }

  String get _subtitleText {
    if (result.isSuccess) {
      return 'Your order is confirmed.\nGet ready for a great experience!';
    }
    if (result.isPending) {
      return 'Your payment is being processed.\nWe\'ll update your order once confirmed.';
    }
    // For failure, show the backend error message if available
    if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
      return result.errorMessage!;
    }
    return 'Something went wrong with your payment.\nPlease try again.';
  }

  String get _primaryButtonText {
    if (result.isSuccess) return 'Track My Order';
    if (result.isPending) return 'Check Order Status';
    return 'Retry Payment';
  }

  void _onPrimaryTap() {
    Navigator.of(Get.context!).pop();

    if (result.isSuccess) {
      // Clear cart then navigate to order tracking
      controller.clearCartAfterPayment();
      // TODO: replace '/home' with your actual order tracking route when ready
      // e.g. Get.offAllNamed(AppRoutes.orderTracking, arguments: {'orderId': controller.placedOrderId})
      Get.offAllNamed('/home');
    } else if (result.isPending) {
      // Go to orders screen so user can monitor status
      Get.offAllNamed('/home');
    } else {
      // Failed — retry the payment (reuses same placedOrderId, no new order created)
      controller.retryPayment();
    }
  }

  void _onSecondaryTap() {
    Navigator.of(Get.context!).pop();
    Get.offAllNamed('/home');
  }
}
