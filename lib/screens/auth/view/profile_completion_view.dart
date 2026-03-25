import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/profile_completion_controller.dart';
import 'widget/location_status_widget.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  late final ProfileCompletionController _controller;
  bool _referralTouched = false;

  bool get _isRejected => _controller.referralRejectedByServer;

  bool get _showReferralSuccess {
    if (_isRejected) return false;
    final code = _controller.referralCodeController.text.trim();
    return code.isNotEmpty && _controller.isReferralCodeValid;
  }

  bool get _showReferralError {
    if (_isRejected) return true;
    if (!_referralTouched) return false;
    final code = _controller.referralCodeController.text.trim();
    return code.isNotEmpty && !_controller.isReferralCodeValid;
  }

  String get _referralErrorMessage {
    if (_isRejected) {
      return 'This referral code is invalid. Tap × to clear it.';
    }
    return 'Format: EAT followed by 9 letters or numbers';
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileCompletionController>();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor,
      body: SafeArea(
        child: GetBuilder<ProfileCompletionController>(
          id: 'profile_completion',
          builder: (_) {
            return Column(
              children: [
                _buildTopBar(responsive),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing20,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: responsive.spacing32),
                        _buildHeroSection(responsive),
                        SizedBox(height: responsive.spacing32),
                        _buildNameSection(context, responsive),
                        SizedBox(height: responsive.spacing20),
                        _buildLocationSection(responsive),
                        SizedBox(height: responsive.spacing20),
                        _buildReferralSection(responsive),
                        SizedBox(height: responsive.spacing40),
                      ],
                    ),
                  ),
                ),
                _buildStickyButton(responsive),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing20,
        vertical: responsive.spacing12,
      ),
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        border: Border(
          bottom: BorderSide(color: AppColor.black.withOpacity(0.05), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColor.appPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: AppColor.appPrimary,
              size: 20,
            ),
          ),
          SizedBox(width: responsive.spacing10),
          text(
            text: 'EatPlek',
            size: responsive.fontSize18,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
          ),
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHeroSection(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing12,
            vertical: responsive.spacing6,
          ),
          decoration: BoxDecoration(
            color: AppColor.appPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColor.appPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: responsive.spacing6),
              text(
                text: 'Last step',
                size: responsive.fontSize12,
                fontWeight: FontWeight.w600,
                color: AppColor.appPrimary,
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.spacing12),
        text(
          text: 'Complete\nYour Profile',
          size: responsive.fontSize28,
          fontWeight: FontWeight.w800,
          color: AppColor.black,
        ),
        SizedBox(height: responsive.spacing8),
        text(
          text: 'Tell us a little about yourself to get started.',
          size: responsive.fontSize14,
          color: AppColor.black.withOpacity(0.5),
        ),
      ],
    );
  }

  // ── Name ──────────────────────────────────────────────────────────────────

  Widget _buildNameSection(BuildContext context, ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Full Name', responsive),
        SizedBox(height: responsive.spacing10),
        buildCommonTextFormField(
          hintText: 'Enter your full name',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          controller: _controller.nameController,
          context: context,
        ),
      ],
    );
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Widget _buildLocationSection(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Location', responsive),
        SizedBox(height: responsive.spacing10),
        LocationStatusWidget(controller: _controller),
      ],
    );
  }

  // ── Referral ──────────────────────────────────────────────────────────────

  Widget _buildReferralSection(ResponsiveHelper responsive) {
    final Color borderColor =
        _showReferralError
            ? AppColor.redColor.withOpacity(0.5)
            : _showReferralSuccess
            ? const Color(0xFF2E7D32).withOpacity(0.4)
            : AppColor.black.withOpacity(0.08);

    final Color focusedBorderColor =
        _showReferralError
            ? AppColor.redColor
            : _showReferralSuccess
            ? const Color(0xFF2E7D32)
            : AppColor.appPrimary;

    final Color textColor =
        _showReferralError
            ? AppColor.redColor
            : _showReferralSuccess
            ? const Color(0xFF2E7D32)
            : AppColor.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _fieldLabel('Referral Code', responsive),
            SizedBox(width: responsive.spacing8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.spacing8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: text(
                text: 'Optional',
                size: responsive.fontSize10,
                fontWeight: FontWeight.w600,
                color: AppColor.appPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.spacing10),

        TextField(
          controller: _controller.referralCodeController,
          textCapitalization: TextCapitalization.characters,
          // ── KEY FIX: readOnly instead of enabled:false ─────────────────
          // enabled:false wraps the field in IgnorePointer which blocks ALL
          // touch events including the suffix icon tap.
          // readOnly:true prevents keyboard/typing but keeps the widget
          // fully hittable so the × button tap registers correctly.
          readOnly: _isRejected,
          inputFormatters: [
            TextInputFormatter.withFunction(
              (oldValue, newValue) =>
                  newValue.copyWith(text: newValue.text.toUpperCase()),
            ),
            LengthLimitingTextInputFormatter(12),
          ],
          onChanged: (_) {
            setState(() => _referralTouched = true);
            _controller.onReferralChanged();
          },
          style: TextStyle(
            fontSize: responsive.fontSize15,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. EAT3930KAN8F',
            hintStyle: TextStyle(
              color: AppColor.black.withOpacity(0.25),
              fontSize: responsive.fontSize14,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor:
                _isRejected
                    ? AppColor.redColor.withOpacity(0.04)
                    : const Color(0xFFF8F8F8),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.spacing16,
              vertical: responsive.spacing14,
            ),
            // ── Suffix icon ──────────────────────────────────────────────
            suffixIcon: _buildSuffixIcon(),
            suffixIconConstraints: const BoxConstraints(minWidth: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.black.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
            ),
          ),
        ),

        // Inline feedback
        if (_showReferralError) ...[
          SizedBox(height: responsive.spacing6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  _isRejected
                      ? Icons.error_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 13,
                  color: AppColor.redColor,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: text(
                  text: _referralErrorMessage,
                  size: responsive.fontSize12,
                  color: AppColor.redColor,
                ),
              ),
            ],
          ),
        ] else if (_showReferralSuccess) ...[
          SizedBox(height: responsive.spacing6),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 13,
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 4),
              text(
                text: 'Valid referral code',
                size: responsive.fontSize12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2E7D32),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Suffix icon builder — separated so it's easy to reason about each state.
  Widget? _buildSuffixIcon() {
    // Server rejected → tappable red × clear button
    if (_isRejected) {
      return IconButton(
        // IconButton is the correct widget here — it handles its own hit area
        // and works correctly inside readOnly TextFields. GestureDetector on a
        // suffix icon can be blocked by the field's internal gesture arena.
        onPressed: () {
          _controller.clearReferralCode();
          setState(() => _referralTouched = false);
        },
        icon: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColor.redColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close_rounded, color: AppColor.redColor, size: 14),
        ),
        splashRadius: 18,
        padding: const EdgeInsets.only(right: 8),
        constraints: const BoxConstraints(),
      );
    }

    // Regex valid → green check
    if (_showReferralSuccess) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(
          Icons.check_circle_rounded,
          color: const Color(0xFF2E7D32),
          size: 20,
        ),
      );
    }

    // Regex error → static red ✗
    if (_showReferralError) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(Icons.cancel_rounded, color: AppColor.redColor, size: 20),
      );
    }

    return null;
  }

  // ── Sticky button ─────────────────────────────────────────────────────────

  Widget _buildStickyButton(ResponsiveHelper responsive) {
    final isDisabled =
        _controller.isLoading ||
        _controller.latitude == null ||
        _controller.longitude == null ||
        !_controller.isReferralCodeValid ||
        _controller.referralRejectedByServer;

    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.spacing20,
        responsive.spacing12,
        responsive.spacing20,
        responsive.spacing20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        border: Border(
          top: BorderSide(color: AppColor.black.withOpacity(0.06), width: 1),
        ),
      ),
      child: button(
        name: 'Complete Profile',
        borderRadius: BorderRadius.circular(responsive.spacing40),
        height: responsive.buttonHeight,
        isLoading: _controller.isLoading,
        onTap: isDisabled ? () {} : _controller.handleProfileCompletion,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _fieldLabel(String label, ResponsiveHelper responsive) {
    return text(
      text: label,
      size: responsive.fontSize16,
      fontWeight: FontWeight.w500,
      color: AppColor.black,
    );
  }
}
