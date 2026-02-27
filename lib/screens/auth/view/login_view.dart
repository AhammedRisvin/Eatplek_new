import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
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
    final responsive = ResponsiveHelper();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GetBuilder<AuthController>(
        id: 'auth_screen',
        builder: (controller) {
          return Stack(
            children: [
              _buildMainContent(context, controller, responsive),
              if (controller.showProfileBottomSheet) ProfileCompletionWidget(controller: controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AuthController controller, ResponsiveHelper responsive) {
    return SizedBox(
      height: responsive.screenHeight,
      width: responsive.screenWidth,
      child: Stack(
        children: [
          // Background image header
          Container(
            width: responsive.screenWidth,
            height: responsive.spacing160 * 1.5,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/image/authbg.png'), fit: BoxFit.cover),
            ),
          ),
          // Content container
          Positioned(
            top: responsive.spacing160 * 1.4,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(responsive.largeBorderRadius),
                  topRight: Radius.circular(responsive.largeBorderRadius),
                ),
              ),
              child: Column(
                children: [
                  // Header section
                  Padding(
                    padding: EdgeInsets.only(top: responsive.spacing20),
                    child: _buildAuthHeader(controller, responsive),
                  ),
                  // Form/OTP content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
                      child: _buildAuthContent(controller, responsive),
                    ),
                  ),
                  // Action buttons
                  _buildAuthActions(context, controller, responsive),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthHeader(AuthController controller, ResponsiveHelper responsive) {
    return Column(
      children: [
        Text(
          controller.title,
          style: TextStyle(fontSize: responsive.fontSize26, fontWeight: FontWeight.w700, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: responsive.spacing10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: Text(
            controller.subtitle,
            style: TextStyle(
              fontSize: responsive.fontSize16,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthContent(AuthController controller, ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.spacing20),
      child:
          controller.isFormStep
              ? LoginFormWidget(controller: controller)
              : OtpVerificationWidget(controller: controller),
    );
  }

  Widget _buildAuthActions(BuildContext context, AuthController controller, ResponsiveHelper responsive) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: responsive.spacing16,
        right: responsive.spacing16,
        top: responsive.spacing16,
        bottom: responsive.spacing16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            name: controller.buttonText,
            borderRadius: BorderRadius.circular(responsive.spacing40),
            height: responsive.buttonHeight,
            isLoading: controller.isLoading,
            onTap: controller.isLoading ? () {} : controller.handleAuthAction,
          ),
          SizedBox(height: responsive.spacing10),
          if (controller.isOtpStep) _buildResendOtpSection(controller, responsive),
        ],
      ),
    );
  }

  Widget _buildResendOtpSection(AuthController controller, ResponsiveHelper responsive) {
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
          Text(
            controller.switchText,
            style: TextStyle(
              fontSize: responsive.fontSize16,
              fontWeight: FontWeight.w500,
              color: AppColor.black.withOpacity(0.6),
            ),
          ),
          SizedBox(width: responsive.spacing6),
          Text(
            controller.switchActionText,
            style: TextStyle(
              fontSize: responsive.fontSize16,
              fontWeight: FontWeight.w700,
              color: isDisabled ? AppColor.black.withOpacity(0.4) : AppColor.appPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
