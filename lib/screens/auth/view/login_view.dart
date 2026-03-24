import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        builder:
            (controller) => Stack(
              children: [
                _buildContent(context, controller, responsive),
                if (controller.showProfileBottomSheet)
                  ProfileCompletionWidget(controller: controller),
              ],
            ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AuthController controller,
    ResponsiveHelper responsive,
  ) {
    return SizedBox(
      height: responsive.screenHeight,
      width: responsive.screenWidth,
      child: Stack(
        children: [
          // ── Background header image ────────────────────────────────────
          Container(
            width: responsive.screenWidth,
            height: responsive.spacing160 * 1.5,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/authbg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ).animate().fade(duration: 500.ms),

          // ── White card ─────────────────────────────────────────────────
          Positioned(
                top: responsive.spacing160 * 1.38,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.only(top: responsive.spacing24),
                        child: _buildHeader(controller, responsive),
                      ),

                      // Form / OTP
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing16,
                          ),
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: responsive.spacing20,
                            ),
                            child:
                                controller.isFormStep
                                    ? LoginFormWidget(controller: controller)
                                    : OtpVerificationWidget(
                                      controller: controller,
                                    ),
                          ),
                        ),
                      ),

                      // Action buttons
                      _buildActions(context, controller, responsive),
                    ],
                  ),
                ),
              )
              .animate()
              .fade(duration: 400.ms, delay: 150.ms)
              .slideY(
                begin: 0.08,
                end: 0,
                duration: 400.ms,
                delay: 150.ms,
                curve: Curves.easeOut,
              ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthController controller, ResponsiveHelper responsive) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            controller.title,
            key: ValueKey(controller.title),
            style: TextStyle(
              fontSize: responsive.fontSize24,
              fontWeight: FontWeight.w800,
              color: AppColor.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: responsive.spacing8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Padding(
            key: ValueKey(controller.subtitle),
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
            child: Text(
              controller.subtitle,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    AuthController controller,
    ResponsiveHelper responsive,
  ) {
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
          // Primary action button
          button(
            name: controller.buttonText,
            borderRadius: BorderRadius.circular(responsive.spacing40),
            height: responsive.buttonHeight,
            isLoading: controller.isLoading,
            onTap: controller.isLoading ? null : controller.handleAuthAction,
          ),

          // Resend OTP link
          if (controller.isOtpStep) ...[
            SizedBox(height: responsive.spacing12),
            _buildResendRow(controller, responsive),
          ],
        ],
      ),
    );
  }

  Widget _buildResendRow(
    AuthController controller,
    ResponsiveHelper responsive,
  ) {
    final canResend = controller.canResend;
    final isDisabled = !canResend || controller.isLoading;

    return GestureDetector(
      onTap: isDisabled ? null : controller.resendOtp,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.switchText,
            style: TextStyle(
              fontSize: responsive.fontSize14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.55),
            ),
          ),
          SizedBox(width: responsive.spacing6),
          Text(
            controller.switchActionText,
            style: TextStyle(
              fontSize: responsive.fontSize14,
              fontWeight: FontWeight.w700,
              color:
                  isDisabled
                      ? AppColor.black.withOpacity(0.3)
                      : AppColor.appPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
