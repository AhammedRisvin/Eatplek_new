import 'package:eatplek_app/core/util/app_color.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../controller/auth_controller.dart';

class OtpVerificationWidget extends StatelessWidget {
  final AuthController controller;

  const OtpVerificationWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Pinput(
        length: 6,
        controller: controller.otpController,
        focusedPinTheme: _buildFocusedTheme(),
        defaultPinTheme: _buildDefaultTheme(),
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        errorPinTheme: _buildErrorTheme(),
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
        },
        onCompleted: (value) {
          controller.handleOtpVerification();
        },
        pinAnimationType: PinAnimationType.fade,
        submittedPinTheme: _buildSubmittedTheme(context),
      ),
    );
  }

  PinTheme _buildFocusedTheme() {
    return PinTheme(
      width: 57,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.scaffoldColor,
        border: Border.all(color: AppColor.appPrimary.withOpacity(0.4)),
      ),
    );
  }

  PinTheme _buildDefaultTheme() {
    return PinTheme(
      width: 57,
      height: 80,
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.black.withOpacity(0.1)),
      ),
    );
  }

  PinTheme _buildErrorTheme() {
    return PinTheme(
      width: 57,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
    );
  }

  PinTheme _buildSubmittedTheme(BuildContext context) {
    return PinTheme(
      height: context.hp(6),
      width: context.hp(6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.4)),
      ),
    );
  }
}
