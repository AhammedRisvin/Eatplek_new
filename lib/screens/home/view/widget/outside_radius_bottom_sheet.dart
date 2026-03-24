import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';

class OutsideRadiusBottomSheet extends StatelessWidget {
  final double distanceKm;
  final String vendorName;
  final VoidCallback onDismiss;

  const OutsideRadiusBottomSheet({
    super.key,
    required this.distanceKm,
    required this.vendorName,
    required this.onDismiss,
  });

  static void show({
    required double distanceKm,
    required String vendorName,
    required VoidCallback onDismiss,
  }) {
    Get.bottomSheet(
      OutsideRadiusBottomSheet(
        distanceKm: distanceKm,
        vendorName: vendorName,
        onDismiss: onDismiss,
      ),
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

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
              color: Colors.orange.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_rounded,
              color: Colors.orange,
              size: responsive.spacing32,
            ),
          ),
          SizedBox(height: responsive.spacing16),

          text(
            text: 'You\'re Too Far Away',
            size: responsive.fontSize18,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing8),

          text(
            text:
                'You are ${distanceKm.toStringAsFixed(1)} km away from $vendorName. '
                'Please change your location to accept this invitation.',
            size: responsive.fontSize14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.55),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing8),

          // Distance badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing16,
              vertical: responsive.spacing8,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing40),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_walk_rounded,
                  size: responsive.spacing16,
                  color: Colors.orange,
                ),
                SizedBox(width: responsive.spacing6),
                text(
                  text: '${distanceKm.toStringAsFixed(1)} km away',
                  size: responsive.fontSize13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.spacing24),

          button(
            name: 'Got It',
            width: responsive.screenWidth,
            fontSize: responsive.fontSize16,
            height: responsive.buttonHeight,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(responsive.spacing40),
            onTap: () {
              Navigator.of(Get.context!).pop();
              onDismiss();
            },
          ),
        ],
      ),
    );
  }
}
