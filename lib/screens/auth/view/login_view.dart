import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import 'widget/login_form_widget.dart';
import 'widget/otp_verification_widget.dart';
import 'widget/profile_completion_widget.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GetBuilder<AuthController>(
        id: 'auth_screen',
        builder: (controller) {
          return Stack(
            children: [
              _buildMainContent(context, controller),
              if (controller.showProfileBottomSheet) ProfileCompletionWidget(controller: controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AuthController controller) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          // Primary header background
          Container(width: context.wp(100), height: 245, color: AppColor.appPrimary),
          // Content container
          Positioned(
            top: 225,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Header section
                  Padding(padding: const EdgeInsets.only(top: 30), child: _buildAuthHeader(controller)),
                  // Form/OTP content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildAuthContent(controller),
                    ),
                  ),
                  // Action buttons
                  _buildAuthActions(context, controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthHeader(AuthController controller) {
    return Column(
      children: [
        text(text: controller.title, size: 26, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
        10.h,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: text(
            text: controller.subtitle,
            fontWeight: FontWeight.w400,
            size: 16,
            color: AppColor.black.withOpacity(0.6),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthContent(AuthController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child:
          controller.isFormStep
              ? LoginFormWidget(controller: controller)
              : OtpVerificationWidget(controller: controller),
    );
  }

  Widget _buildAuthActions(BuildContext context, AuthController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            name: controller.buttonText,
            borderRadius: BorderRadius.circular(50),
            height: 60,
            isLoading: controller.isLoading,
            onTap: controller.isLoading ? () {} : controller.handleAuthAction,
          ),
          10.h,
          if (controller.isOtpStep) _buildResendOtpSection(controller),
        ],
      ),
    );
  }

  Widget _buildResendOtpSection(AuthController controller) {
    final canResend = controller.canResend;
    final isDisabled = !canResend || controller.isLoading;

    return GestureDetector(
      onTap:
          isDisabled
              ? null
              : () {
                if (canResend) controller.resendOtp();
              },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          text(
            text: controller.switchText,
            size: 16,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.6),
          ),
          6.w,
          text(
            text: controller.switchActionText,
            size: 16,
            fontWeight: FontWeight.w700,
            color: isDisabled ? AppColor.black.withOpacity(0.4) : AppColor.appPrimary,
          ),
        ],
      ),
    );
  }
}
