import 'package:eatplek_app/core/util/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/common_widgets.dart';
import '../../../core/util/responsive_helper.dart';
import '../controller/refer_controller.dart';

class ReferScreen extends StatelessWidget {
  ReferScreen({super.key});

  final ReferController _controller = Get.find<ReferController>();
  final ResponsiveHelper _r = ResponsiveHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Gradient background — covers 3/4 of screen, fades to white ──
          Container(
            height: _r.screenHeight * 0.75,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.appPrimary,
                  AppColor.appPrimary.withOpacity(0.55),
                  AppColor.appPrimary.withOpacity(0.15),
                  AppColor.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.45, 0.75, 1.0],
              ),
            ),
          ),

          // ── Content ──
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: _r.topPadding + _r.spacing30),

                      SizedBox(height: _r.spacing40),
                      // ── Illustration ──
                      Center(
                        child: Image.asset(
                          referPng,
                          height: _r.spacing(210),
                          width: _r.widthPercent(90),
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: _r.spacing40),

                      // ── Title & subtitle ──
                      Padding(
                        padding: _r.horizontalPadding20,
                        child: Column(
                          children: [
                            text(
                              text: 'Refer friends. Earn up to ₹100!',
                              size: _r.fontSize28,
                              fontWeight: FontWeight.bold,
                              color: AppColor.black,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: _r.spacing12),
                            text(
                              text:
                                  'Get ₹100 when your friend signs up and orders.',
                              size: _r.fontSize14,
                              color: AppColor.hintTextColor,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: _r.spacing30),

                            // ── Referral Code Field ──
                            Obx(() {
                              if (_controller.isLoading.value) {
                                return _buildCodeSkeleton();
                              }
                              if (_controller.hasError.value) {
                                return _buildErrorState();
                              }
                              return _buildReferralCodeField();
                            }),
                          ],
                        ),
                      ),

                      SizedBox(height: _r.spacing24),
                    ],
                  ),
                ),
              ),

              // ── Bottom buttons ──
              Padding(
                padding: EdgeInsets.only(
                  left: _r.spacing20,
                  right: _r.spacing20,
                  bottom: _r.spacing20 + _r.bottomPadding,
                ),
                child: Column(
                  children: [
                    // Share via WhatsApp
                    button(
                      name: 'Share via WhatsApp',
                      height: _r.buttonHeight,
                      borderRadius: BorderRadius.circular(_r.cardBorderRadius),
                      onTap: _onShareWhatsApp,
                    ),
                    SizedBox(height: _r.spacing12),
                    // Back button
                    button(
                      name: 'Back',
                      height: _r.buttonHeight,
                      borderRadius: BorderRadius.circular(_r.cardBorderRadius),
                      color: Colors.transparent,
                      textColor: AppColor.appPrimary,
                      borderColor: AppColor.appPrimary,
                      onTap: () => Get.back(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeField() {
    return buildCommonTextFormField(
      context: Get.context!,
      hintText:
          'Your Referral Code : ${_controller.referralCode.value.isEmpty ? "—" : _controller.referralCode.value}',
      hintTextColor: AppColor.black,
      keyboardType: TextInputType.none,
      textInputAction: TextInputAction.none,
      controller: null,
      readOnly: true,
      enabled: false,
      bgColor: AppColor.white,
      borderColor: Colors.black12,
      radius: _r.cardBorderRadius,

      suffixIcon: GestureDetector(
        onTap: _onCopy,
        child: Container(
          margin: EdgeInsets.all(_r.spacing8),
          width: _r.spacing40,
          height: _r.spacing40,
          decoration: BoxDecoration(
            color: AppColor.appPrimary,
            borderRadius: BorderRadius.circular(_r.smallBorderRadius),
          ),
          padding: EdgeInsets.all(_r.spacing8),
          child: Image.asset(copyPng, color: AppColor.white),
        ),
      ),
    );
  }

  Widget _buildCodeSkeleton() {
    return Container(
      height: _r.spacing(56),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(_r.cardBorderRadius),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        text(
          text: _controller.errorMessage.value,
          size: _r.fontSize13,
          color: Colors.redAccent,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: _r.spacing12),
        GestureDetector(
          onTap: () => _controller.fetchReferral(forceRefresh: true),
          child: text(
            text: 'Retry',
            size: _r.fontSize13,
            color: AppColor.appPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _onCopy() {
    final code = _controller.referralCode.value;
    if (code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: text(
        text: 'Referral code copied to clipboard!',
        size: 13,
        color: AppColor.white,
      ),
      backgroundColor: AppColor.appPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(_r.spacing16),
      borderRadius: _r.cardBorderRadius,
      duration: const Duration(seconds: 2),
    );
  }

  void _onShareWhatsApp() {
    final code = _controller.referralCode.value;
    if (code.isEmpty) {
      Get.snackbar(
        '',
        '',
        titleText: const SizedBox.shrink(),
        messageText: text(
          text: 'Referral code not available yet.',
          size: 13,
          color: AppColor.white,
        ),
        backgroundColor: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(_r.spacing16),
        borderRadius: _r.cardBorderRadius,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    final message = Uri.encodeComponent(
      'Hey! Use my referral code *$code* on EatPlek and earn ₹100 when you sign up and order! 🎉',
    );
    // Uncomment when url_launcher is added:
    // launchUrl(Uri.parse('https://wa.me/?text=$message'), mode: LaunchMode.externalApplication);
  }
}
