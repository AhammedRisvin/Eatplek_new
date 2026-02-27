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
        borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.extraLargeBorderRadius)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Drag indicator
            Align(
              alignment: Alignment.center,
              child: Container(
                width: responsive.spacing120,
                height: responsive.spacing4,
                margin: EdgeInsets.only(bottom: responsive.spacing10),
                decoration: BoxDecoration(
                  color: const Color(0XFFD9D9D9),
                  borderRadius: BorderRadius.circular(responsive.extraLargeBorderRadius),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing6),

            // ✅ Title
            text(
              text: 'Reschedule Requested by Restaurant',
              size: responsive.fontSize22,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing6),

            // ✅ Description
            text(
              text:
                  controller.rejectionReason ??
                  'The restaurant is unable to prepare your order at your selected time. They have suggested a new time for you.',
              size: responsive.fontSize14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: responsive.spacing20),

            // ✅ TIME COMPARISON BOXES (Shown initially, hidden when time picker is visible)
            GetBuilder<OrderConfirmationController>(
              id: 'time_suggestion_sheet',
              builder: (controller) {
                return AnimatedOpacity(
                  opacity: !controller.isTimeSuggestionTimePickerVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child:
                      !controller.isTimeSuggestionTimePickerVisible
                          ? Column(
                            children: [
                              // ✅ USER'S ORIGINAL SELECTED TIME BOX
                              Container(
                                width: responsive.widthPercent(100),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                                  border: Border.all(color: const Color(0xff000000).withOpacity(0.06)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff000000).withOpacity(0.04),
                                      blurRadius: 24,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(responsive.spacing20),
                                margin: EdgeInsets.only(bottom: responsive.spacing12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    text(
                                      text: 'Your Selected Time',
                                      size: responsive.fontSize16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.black,
                                    ),
                                    SizedBox(height: responsive.spacing12),
                                    Container(
                                      width: responsive.widthPercent(100),
                                      decoration: BoxDecoration(
                                        color: AppColor.scaffoldColor,
                                        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                                        border: Border.all(color: const Color(0xff000000).withOpacity(0.06)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xff000000).withOpacity(0.04),
                                            blurRadius: 24,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: responsive.spacing16,
                                        vertical: responsive.spacing10,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: text(
                                          text: controller.getFormattedTime(),
                                          size: responsive.fontSize16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.black.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ✅ RESTAURANT SUGGESTED TIME BOX
                              Container(
                                width: responsive.widthPercent(100),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                  boxShadow: [
                                    BoxShadow(color: Colors.green.withOpacity(0.05), blurRadius: 24, spreadRadius: 0),
                                  ],
                                ),
                                padding: EdgeInsets.all(responsive.spacing20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up_alt_outlined,
                                          size: responsive.iconSizeSmall,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: responsive.spacing8),
                                        text(
                                          text: 'Restaurant Suggested Time',
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
                                        color: Colors.green.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                                        border: Border.all(color: Colors.green.withOpacity(0.2)),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: responsive.spacing16,
                                        vertical: responsive.spacing10,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: text(
                                          text: controller.getFormattedSuggestedTime(),
                                          size: responsive.fontSize16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: responsive.spacing20),
                            ],
                          )
                          : const SizedBox.shrink(),
                );
              },
            ),

            // ✅ TIME PICKER WIDGET (Shown when user taps "Select New Time")
            GetBuilder<OrderConfirmationController>(
              id: 'time_suggestion_sheet',
              builder: (controller) {
                return AnimatedOpacity(
                  opacity: controller.isTimeSuggestionTimePickerVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child:
                      controller.isTimeSuggestionTimePickerVisible
                          ? Column(
                            children: [
                              ResponsiveTimeSelectingWidget(controller: controller),
                              SizedBox(height: responsive.spacing20),
                            ],
                          )
                          : const SizedBox.shrink(),
                );
              },
            ),

            // ✅ BUTTONS (Dynamic based on time picker visibility)
            GetBuilder<OrderConfirmationController>(
              id: 'time_suggestion_sheet',
              builder: (controller) {
                return controller.isTimeSuggestionTimePickerVisible
                    // ✅ SINGLE SUBMIT BUTTON (When time picker is visible)
                    ? Column(
                      children: [
                        button(
                          name: 'Submit',
                          width: responsive.widthPercent(100),
                          height: responsive.formFieldHeight,
                          borderRadius: BorderRadius.circular(responsive.extraLargeBorderRadius),
                          fontSize: responsive.fontSize16,
                          fontWeight: FontWeight.w600,
                          onTap: () async {
                            await controller.submitCustomTimeSelection();
                          },
                        ),
                        SizedBox(height: responsive.spacing10),
                      ],
                    )
                    // ✅ TWO BUTTONS (Initial state - time picker hidden)
                    : Column(
                      children: [
                        Row(
                          children: [
                            // ✅ Select New Time Button (Outline)
                            Expanded(
                              child: button(
                                name: 'Select New Time',
                                height: responsive.formFieldHeight,
                                borderRadius: BorderRadius.circular(responsive.extraLargeBorderRadius),
                                fontSize: responsive.fontSize16,
                                fontWeight: FontWeight.w600,
                                onTap: () {
                                  controller.toggleTimeSuggestionTimePicker();
                                },
                                borderColor: AppColor.appPrimary,
                                textColor: AppColor.appPrimary,
                                color: AppColor.transparent,
                              ),
                            ),
                            SizedBox(width: responsive.spacing20),

                            // ✅ Accept Suggestion Button (Filled)
                            Expanded(
                              child: button(
                                name: 'Accept Suggestion',
                                height: responsive.formFieldHeight,
                                borderRadius: BorderRadius.circular(responsive.extraLargeBorderRadius),
                                fontSize: responsive.fontSize16,
                                fontWeight: FontWeight.w600,
                                onTap: () async {
                                  await controller.acceptSuggestedTime();
                                },
                              ),
                            ),
                          ],
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
}
