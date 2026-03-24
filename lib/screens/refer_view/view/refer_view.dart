import 'package:eatplek_app/core/util/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.all(_r.spacing8),
            decoration: BoxDecoration(
              color: AppColor.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColor.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────────────────
          Container(
            height: _r.screenHeight * 0.72,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.appPrimary,
                  AppColor.appPrimary.withOpacity(0.6),
                  AppColor.appPrimary.withOpacity(0.1),
                  AppColor.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.4, 0.72, 1.0],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: _r.topPadding + _r.spacing60),

                      // Illustration
                      Center(
                            child: Image.asset(
                              referPng,
                              height: _r.spacing(200),
                              width: _r.widthPercent(85),
                              fit: BoxFit.contain,
                            ),
                          )
                          .animate()
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                            curve: Curves.easeOutBack,
                          )
                          .fade(duration: 400.ms),

                      SizedBox(height: _r.spacing32),

                      // Title + subtitle
                      Padding(
                        padding: _r.horizontalPadding20,
                        child: Column(
                          children: [
                            text(
                                  text: 'Refer & Earn ₹100!',
                                  size: _r.fontSize26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.black,
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .fade(duration: 400.ms, delay: 150.ms)
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 400.ms,
                                  delay: 150.ms,
                                ),

                            SizedBox(height: _r.spacing10),

                            text(
                              text:
                                  'Get ₹100 when your friend signs up and places their first order.',
                              size: _r.fontSize14,
                              color: AppColor.black.withOpacity(0.5),
                              textAlign: TextAlign.center,
                            ).animate().fade(duration: 400.ms, delay: 200.ms),

                            SizedBox(height: _r.spacing28),

                            // Referral code card
                            Obx(() {
                                  if (_controller.isLoading.value) {
                                    return _buildCodeSkeleton();
                                  }
                                  if (_controller.hasError.value) {
                                    return _buildErrorWidget();
                                  }
                                  return _buildCodeCard();
                                })
                                .animate()
                                .fade(duration: 400.ms, delay: 250.ms)
                                .slideY(
                                  begin: 0.15,
                                  end: 0,
                                  duration: 400.ms,
                                  delay: 250.ms,
                                ),
                          ],
                        ),
                      ),

                      SizedBox(height: _r.spacing24),

                      // How it works steps
                      _buildHowItWorks().animate().fade(
                        duration: 400.ms,
                        delay: 300.ms,
                      ),

                      SizedBox(height: _r.spacing24),
                    ],
                  ),
                ),
              ),

              // ── Bottom buttons ─────────────────────────────────────────────
              _buildBottomButtons()
                  .animate()
                  .fade(duration: 400.ms, delay: 350.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 350.ms),
            ],
          ),
        ],
      ),
    );
  }

  // ── Referral code card ────────────────────────────────────────────────────
  Widget _buildCodeCard() {
    final code = _controller.referralCode.value;

    return Container(
      padding: EdgeInsets.all(_r.spacing16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_r.largeBorderRadius),
        border: Border.all(color: AppColor.appPrimary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColor.appPrimary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Code section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: 'Your Referral Code',
                  size: _r.fontSize11,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.45),
                  letterSpacing: 0.5,
                ),
                SizedBox(height: _r.spacing4),
                text(
                  text: code.isEmpty ? '—' : code,
                  size: _r.fontSize22,
                  fontWeight: FontWeight.w800,
                  color: AppColor.appPrimary,
                  letterSpacing: 2.0,
                ),
              ],
            ),
          ),

          // Copy button
          GestureDetector(
            onTap: code.isEmpty ? null : _onCopy,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _r.spacing14,
                vertical: _r.spacing10,
              ),
              decoration: BoxDecoration(
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.circular(_r.cardBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.appPrimary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.copy_rounded,
                    color: AppColor.white,
                    size: 14,
                  ),
                  SizedBox(width: _r.spacing5),
                  text(
                    text: 'Copy',
                    size: _r.fontSize12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSkeleton() {
    return Container(
      height: _r.spacing(72),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(_r.largeBorderRadius),
      ),
    );
  }

  Widget _buildErrorWidget() {
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── How it works ──────────────────────────────────────────────────────────
  Widget _buildHowItWorks() {
    final steps = [
      (
        Icons.share_rounded,
        'Share your code',
        'Send your referral code to friends',
      ),
      (
        Icons.person_add_rounded,
        'Friend signs up',
        'They register using your code',
      ),
      (
        Icons.currency_rupee_rounded,
        'Earn ₹100',
        'Get credited after their first order',
      ),
    ];

    return Padding(
      padding: _r.horizontalPadding20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            text: 'How it works',
            size: _r.fontSize15,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
          ),
          SizedBox(height: _r.spacing14),
          ...steps.asMap().entries.map((e) {
            final i = e.key;
            final step = e.value;
            return Padding(
              padding: EdgeInsets.only(bottom: _r.spacing12),
              child: Row(
                children: [
                  Container(
                    width: _r.spacing40,
                    height: _r.spacing40,
                    decoration: BoxDecoration(
                      color: AppColor.appPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(_r.cardBorderRadius),
                    ),
                    child: Icon(
                      step.$1,
                      color: AppColor.appPrimary,
                      size: _r.fontSize18,
                    ),
                  ),
                  SizedBox(width: _r.spacing14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(
                          text: step.$2,
                          size: _r.fontSize13,
                          fontWeight: FontWeight.w600,
                          color: AppColor.black,
                        ),
                        text(
                          text: step.$3,
                          size: _r.fontSize12,
                          fontWeight: FontWeight.w400,
                          color: AppColor.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Bottom buttons ────────────────────────────────────────────────────────
  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.only(
        left: _r.spacing20,
        right: _r.spacing20,
        bottom: _r.spacing20 + _r.bottomPadding,
      ),
      child: Column(
        children: [
          button(
            name: 'Share via WhatsApp',
            height: _r.buttonHeight,
            borderRadius: BorderRadius.circular(_r.cardBorderRadius),
            onTap: _onShareWhatsApp,
          ),
          SizedBox(height: _r.spacing12),
          button(
            name: 'Back',
            height: _r.buttonHeight,
            borderRadius: BorderRadius.circular(_r.cardBorderRadius),
            color: Colors.transparent,
            textColor: AppColor.appPrimary,
            borderColor: AppColor.appPrimary.withOpacity(0.3),
            onTap: () => Get.back(),
          ),
        ],
      ),
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
        text: '✓  Referral code copied!',
        size: 13,
        color: AppColor.white,
        fontWeight: FontWeight.w500,
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
        'Not ready',
        'Referral code not available yet.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final message = Uri.encodeComponent(
      'Hey! Use my referral code *$code* on EatPlek and earn ₹100 when you sign up and order! 🎉',
    );
    launchUrl(
      Uri.parse('https://wa.me/?text=$message'),
      mode: LaunchMode.externalApplication,
    );
  }
}
