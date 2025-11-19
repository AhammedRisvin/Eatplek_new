import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';
import 'banner_carousal_section.dart';

class ErrorScreenSection extends StatelessWidget {
  final HomeController controller;

  const ErrorScreenSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            20.h,
            BannerCarouselSection(controller: controller),
            SizedBox(
              height: Get.height * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: AppColor.redColor),
                  20.h,
                  text(
                    text: _getErrorTitle(controller.errorMessage),
                    size: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                    textAlign: TextAlign.center,
                  ),
                  12.h,
                  text(
                    text:
                        controller.errorMessage.isEmpty
                            ? 'Unable to load data. Please try again.'
                            : controller.errorMessage,
                    size: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.6),
                    textAlign: TextAlign.center,
                  ),
                  30.h,
                  if (!_isLocationError(controller.errorMessage))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        button(
                          name: 'Retry',
                          width: 120,
                          height: 45,
                          borderRadius: BorderRadius.circular(12),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          onTap: controller.retryFetchingVendors,
                        ),
                        15.w,
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
