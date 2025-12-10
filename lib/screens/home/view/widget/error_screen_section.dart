import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/home_controller.dart';
import 'banner_carousal_section.dart';

class ErrorScreenSection extends StatelessWidget {
  final HomeController controller;

  const ErrorScreenSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return SingleChildScrollView(
      child: Padding(
        padding: responsive.horizontalPadding20,
        child: Column(
          children: [
            SizedBox(height: responsive.spacing20),
            BannerCarouselSection(controller: controller),
            SizedBox(
              height: responsive.heightPercent(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: responsive.iconSizeXL, color: AppColor.redColor),
                  SizedBox(height: responsive.spacing20),
                  text(
                    text: _getErrorTitle(controller.errorMessage),
                    size: responsive.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsive.spacing12),
                  text(
                    text:
                        controller.errorMessage.isEmpty
                            ? 'Unable to load data. Please try again.'
                            : controller.errorMessage,
                    size: responsive.fontSize14,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.6),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsive.spacing30),
                  if (!_isLocationError(controller.errorMessage))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        button(
                          name: 'Retry',
                          width: responsive.spacing120,
                          height: responsive.buttonHeight,
                          borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
                          fontSize: responsive.fontSize16,
                          fontWeight: FontWeight.w600,
                          onTap: controller.retryFetchingVendors,
                        ),
                        SizedBox(width: responsive.spacing15),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Determine error title based on message
  String _getErrorTitle(String message) {
    if (message.contains('No services available')) {
      return 'No Services Available';
    }
    return 'Oops! Something went wrong';
  }

  /// Check if error is location-related
  bool _isLocationError(String message) {
    return message.contains('location') || message.contains('services available');
  }
}
