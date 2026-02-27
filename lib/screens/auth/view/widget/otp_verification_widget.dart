import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../controller/auth_controller.dart';

class OtpVerificationWidget extends StatelessWidget {
  final AuthController controller;

  const OtpVerificationWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Center(
      child: Pinput(
        length: 6,
        controller: controller.otpController,
        focusedPinTheme: _buildFocusedTheme(responsive),
        defaultPinTheme: _buildDefaultTheme(responsive),
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        errorPinTheme: _buildErrorTheme(responsive),
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
        },
        onCompleted: (value) {
          controller.handleOtpVerification();
        },
        pinAnimationType: PinAnimationType.fade,
        submittedPinTheme: _buildSubmittedTheme(context, responsive),
      ),
    );
  }

  PinTheme _buildFocusedTheme(ResponsiveHelper responsive) {
    return PinTheme(
      width: responsive.spacing50,
      height: responsive.spacing80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
        color: AppColor.scaffoldColor,
        border: Border.all(color: AppColor.appPrimary.withOpacity(0.4)),
      ),
    );
  }

  PinTheme _buildDefaultTheme(ResponsiveHelper responsive) {
    return PinTheme(
      width: responsive.spacing50,
      height: responsive.spacing80,
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        border: Border.all(color: AppColor.black.withOpacity(0.1)),
      ),
    );
  }

  PinTheme _buildErrorTheme(ResponsiveHelper responsive) {
    return PinTheme(
      width: responsive.spacing50,
      height: responsive.spacing80,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
    );
  }

  PinTheme _buildSubmittedTheme(BuildContext context, ResponsiveHelper responsive) {
    return PinTheme(
      height: responsive.spacing80,
      width: responsive.spacing80,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
        border: Border.all(color: Colors.green.withOpacity(0.4)),
      ),
    );
  }
}
