import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';

class ClearCartToJoinBottomSheet extends StatefulWidget {
  final VoidCallback onClearAndRetry;
  final VoidCallback onCancel;

  const ClearCartToJoinBottomSheet({
    super.key,
    required this.onClearAndRetry,
    required this.onCancel,
  });

  static void show({
    required VoidCallback onClearAndRetry,
    required VoidCallback onCancel,
  }) {
    Get.bottomSheet(
      ClearCartToJoinBottomSheet(
        onClearAndRetry: onClearAndRetry,
        onCancel: onCancel,
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  @override
  State<ClearCartToJoinBottomSheet> createState() =>
      _ClearCartToJoinBottomSheetState();
}

class _ClearCartToJoinBottomSheetState
    extends State<ClearCartToJoinBottomSheet> {
  bool _isClearing = false;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.screenWidth,
      padding: EdgeInsets.only(
        left: responsive.spacing24,
        right: responsive.spacing24,
        top: responsive.spacing20,
        bottom: responsive.bottomPadding + responsive.spacing20,
      ),
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: responsive.spacing120,
            height: responsive.spacing4,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            ),
          ),
          SizedBox(height: responsive.spacing24),

          // Icon
          Container(
            width: responsive.spacing60,
            height: responsive.spacing60,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: Colors.redAccent,
              size: responsive.spacing32,
            ),
          ),
          SizedBox(height: responsive.spacing16),

          text(
            text: 'Your Cart Has Items',
            size: responsive.fontSize18,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing8),

          text(
            text:
                'You have items in your own cart. Please clear it before joining your friend\'s shared cart.',
            size: responsive.fontSize14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.55),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing24),

          // Clear & Join button
          GestureDetector(
            onTap:
                _isClearing
                    ? null
                    : () async {
                      setState(() => _isClearing = true);
                      widget.onClearAndRetry();
                    },
            child: Container(
              width: responsive.screenWidth,
              height: responsive.buttonHeight,
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                borderRadius: BorderRadius.circular(responsive.spacing40),
              ),
              child: Center(
                child:
                    _isClearing
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: responsive.spacing18,
                              height: responsive.spacing18,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: responsive.spacing10),
                            Text(
                              'Clearing Cart...',
                              style: TextStyle(
                                fontSize: responsive.fontSize16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          'Clear Cart & Join',
                          style: TextStyle(
                            fontSize: responsive.fontSize16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing12),

          // Cancel
          GestureDetector(
            onTap:
                _isClearing
                    ? null
                    : () {
                      Navigator.of(Get.context!).pop();
                      widget.onCancel();
                    },
            child: Container(
              height: responsive.buttonHeight,
              width: responsive.screenWidth,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(responsive.spacing40),
                border: Border.all(color: AppColor.black.withOpacity(0.15)),
              ),
              child: Center(
                child: text(
                  text: 'Cancel',
                  size: responsive.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
