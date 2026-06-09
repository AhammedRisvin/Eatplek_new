import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/order_confirmation_controller.dart';
import 'time_selection_widget.dart';

class TimeSuggestBottomSheet extends StatelessWidget {
  final OrderConfirmationController controller;

  const TimeSuggestBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.bottomSheetPadding,
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.extraLargeBorderRadius),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Drag indicator ──────────────────────────────────────────
            Align(
              alignment: Alignment.center,
              child: Container(
                width: responsive.spacing120,
                height: responsive.spacing4,
                margin: EdgeInsets.only(bottom: responsive.spacing10),
                decoration: BoxDecoration(
                  color: const Color(0XFFD9D9D9),
                  borderRadius: BorderRadius.circular(
                    responsive.extraLargeBorderRadius,
                  ),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing6),

            // ── Title ───────────────────────────────────────────────────
            text(
              text: 'Reschedule Requested by Restaurant',
              size: responsive.fontSize22,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing6),

            // ── Rejection reason / description ──────────────────────────
            text(
              text:
                  controller.rejectionReason ??
                  (controller.hasSuggestedTime()
                      ? 'The restaurant is unable to prepare your order at your selected time. '
                          'They have suggested a new time for you.'
                      : 'The restaurant requested a time update, but no suggested time was returned. '
                          'Please select a new time.'),
              size: responsive.fontSize14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: responsive.spacing20),

            // ── Dynamic body (time comparison  ↔  time picker) ──────────
            GetBuilder<OrderConfirmationController>(
              id: 'time_suggestion_sheet',
              builder: (controller) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      controller.isTimeSuggestionTimePickerVisible
                          // ── TIME PICKER VIEW ─────────────────────────────
                          ? Column(
                            key: const ValueKey('picker'),
                            children: [
                              // ✅ Hint: new time must be after suggested time
                              Container(
                                width: responsive.widthPercent(100),
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.spacing12,
                                  vertical: responsive.spacing10,
                                ),
                                margin: EdgeInsets.only(
                                  bottom: responsive.spacing12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(
                                    responsive.inputBorderRadius,
                                  ),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: responsive.iconSizeSmall,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: responsive.spacing8),
                                    Expanded(
                                      child: text(
                                        text:
                                            'Select a time after ${controller.getFormattedSuggestedTime()} '
                                            'and at least 30 minutes from now.',
                                        size: responsive.fontSize12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ✅ Time picker — validation runs against
                              //    the suggestion-flow rules on every change.
                              ResponsiveTimeSelectingWidget(
                                controller: controller,
                                onTimeChanged: () {
                                  // Trigger suggestion-flow validation live
                                  controller.isTimeSuggestionTimePickerVisible
                                      ? controller
                                          .isTimeValidForSuggestionFlow()
                                      : null;
                                },
                              ),
                              SizedBox(height: responsive.spacing20),
                            ],
                          )
                          // ── TIME COMPARISON VIEW ─────────────────────────
                          : Column(
                            key: const ValueKey('comparison'),
                            children: [
                              // ✅ User's original selected time
                              _buildTimeBox(
                                responsive: responsive,
                                label: 'Your Selected Time',
                                timeText: controller.getFormattedTime(),
                                borderColor: AppColor.black.withOpacity(0.06),
                                timeBackground: AppColor.scaffoldColor,
                                timeTextColor: AppColor.black.withOpacity(0.6),
                                icon: null,
                              ),
                              SizedBox(height: responsive.spacing12),

                              if (controller.hasSuggestedTime()) ...[
                                // ✅ Restaurant's suggested time
                                _buildTimeBox(
                                  responsive: responsive,
                                  label: 'Restaurant Suggested Time',
                                  timeText:
                                      controller.getFormattedSuggestedTime(),
                                  borderColor: Colors.green.withOpacity(0.3),
                                  timeBackground: Colors.green.withOpacity(
                                    0.05,
                                  ),
                                  timeTextColor: Colors.green,
                                  icon: Icon(
                                    Icons.thumb_up_alt_outlined,
                                    size: responsive.iconSizeSmall,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                              SizedBox(height: responsive.spacing20),
                            ],
                          ),
                );
              },
            ),

            // ── Action buttons ──────────────────────────────────────────
            GetBuilder<OrderConfirmationController>(
              id: 'time_suggestion_sheet',
              builder: (controller) {
                return controller.isTimeSuggestionTimePickerVisible
                    // ── Submit (custom time) ─────────────────────────
                    ? Column(
                      children: [
                        button(
                          name: 'Submit',
                          width: responsive.widthPercent(100),
                          height: responsive.formFieldHeight,
                          borderRadius: BorderRadius.circular(
                            responsive.extraLargeBorderRadius,
                          ),
                          fontSize: responsive.fontSize16,
                          fontWeight: FontWeight.w600,
                          onTap: () async {
                            await controller.submitCustomTimeSelection();
                          },
                        ),
                        SizedBox(height: responsive.spacing10),

                        // Back link to return to comparison view
                        GestureDetector(
                          onTap:
                              () => controller.resetTimeToOriginalSelection(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: responsive.spacing8,
                            ),
                            child: text(
                              text: '← Back to time options',
                              size: responsive.fontSize14,
                              fontWeight: FontWeight.w500,
                              color: AppColor.appPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.spacing10),
                      ],
                    )
                    // ── Select New Time / Accept Suggestion ──────────
                    : Column(
                      children: [
                        controller.hasSuggestedTime()
                            ? Row(
                              children: [
                                // Outline button — pick a different time
                                Expanded(
                                  child: button(
                                    name: 'Select New Time',
                                    height: responsive.formFieldHeight,
                                    borderRadius: BorderRadius.circular(
                                      responsive.extraLargeBorderRadius,
                                    ),
                                    fontSize: responsive.fontSize16,
                                    fontWeight: FontWeight.w600,
                                    onTap: () {
                                      controller
                                          .toggleTimeSuggestionTimePicker();
                                    },
                                    borderColor: AppColor.appPrimary,
                                    textColor: AppColor.appPrimary,
                                    color: AppColor.transparent,
                                  ),
                                ),
                                SizedBox(width: responsive.spacing20),

                                // Filled button — accept restaurant's time
                                Expanded(
                                  child: button(
                                    name: 'Accept Suggestion',
                                    height: responsive.formFieldHeight,
                                    borderRadius: BorderRadius.circular(
                                      responsive.extraLargeBorderRadius,
                                    ),
                                    fontSize: responsive.fontSize16,
                                    fontWeight: FontWeight.w600,
                                    onTap: () async {
                                      await controller.acceptSuggestedTime();
                                    },
                                  ),
                                ),
                              ],
                            )
                            : button(
                              name: 'Select New Time',
                              width: responsive.widthPercent(100),
                              height: responsive.formFieldHeight,
                              borderRadius: BorderRadius.circular(
                                responsive.extraLargeBorderRadius,
                              ),
                              fontSize: responsive.fontSize16,
                              fontWeight: FontWeight.w600,
                              onTap: () {
                                controller.toggleTimeSuggestionTimePicker();
                              },
                            ),
                        SizedBox(height: responsive.spacing10),
                      ],
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper: reusable time display box ─────────────────────────────────────
  Widget _buildTimeBox({
    required ResponsiveHelper responsive,
    required String label,
    required String timeText,
    required Color borderColor,
    required Color timeBackground,
    required Color timeTextColor,
    required Widget? icon,
  }) {
    return Container(
      width: responsive.widthPercent(100),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff000000).withOpacity(0.04),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(responsive.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[icon, SizedBox(width: responsive.spacing8)],
              text(
                text: label,
                size: responsive.fontSize16,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
            ],
          ),
          SizedBox(height: responsive.spacing12),
          Container(
            width: responsive.widthPercent(100),
            decoration: BoxDecoration(
              color: timeBackground,
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
              border: Border.all(color: borderColor.withOpacity(0.5)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing16,
              vertical: responsive.spacing10,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: text(
                text: timeText,
                size: responsive.fontSize16,
                fontWeight: FontWeight.w600,
                color: timeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
