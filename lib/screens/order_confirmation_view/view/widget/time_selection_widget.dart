import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/assets.dart';
import '../../controller/order_confirmation_controller.dart';

class TimeSelectingWidget extends StatelessWidget {
  final OrderConfirmationController controller;

  const TimeSelectingWidget({super.key, required this.controller});

  Widget _buildTimePickerButton({
    required String value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 9, horizontal: 9),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColor.black.withOpacity(0.03)),
              boxShadow: [
                BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0)),
              ],
            ),
            child: Center(child: Icon(Icons.keyboard_arrow_up_rounded, color: Color(0XFF454545), size: 30)),
          ),
        ),
        text(text: value, size: 18, fontWeight: FontWeight.w400, color: AppColor.black),
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 9, horizontal: 9),
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColor.black.withOpacity(0.03)),
              boxShadow: [
                BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0)),
              ],
            ),
            child: Center(child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0XFF454545), size: 30)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.wp(100),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.string(dineTimeCalender),
              12.w,
              text(text: 'Select Your Dining Time', size: 16, fontWeight: FontWeight.w500),
            ],
          ),
          30.h,
          GetBuilder<OrderConfirmationController>(
            id: 'time_widget',
            builder: (controller) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour picker
                  _buildTimePickerButton(
                    value: controller.selectedHour.toString().padLeft(2, '0'),
                    onIncrement: controller.incrementHour,
                    onDecrement: controller.decrementHour,
                  ),
                  24.w,
                  text(text: ':', size: 20, fontWeight: FontWeight.w400, color: AppColor.black),
                  24.w,
                  // Minute picker
                  _buildTimePickerButton(
                    value: controller.selectedMinute.toString().padLeft(2, '0'),
                    onIncrement: controller.incrementMinute,
                    onDecrement: controller.decrementMinute,
                  ),
                  24.w,
                  text(text: ':', size: 20, fontWeight: FontWeight.w400, color: AppColor.black),
                  24.w,
                  // Period picker (AM/PM)
                  _buildTimePickerButton(
                    value: controller.selectedPeriod,
                    onIncrement: controller.togglePeriod,
                    onDecrement: controller.togglePeriod,
                  ),
                ],
              );
            },
          ),
          30.h,
          GetBuilder<OrderConfirmationController>(
            id: 'time_widget',
            builder: (controller) {
              return Column(
                children: [
                  text(
                    text: 'Selected Time: ${controller.getFormattedTime()}',
                    size: 16,
                    fontWeight: FontWeight.w600,
                    color: controller.timeErrorMessage != null ? Colors.red : AppColor.appPrimary,
                  ),

                  // Show error message if there's one
                  if (controller.timeErrorMessage != null) ...[
                    8.h,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 16, color: Colors.red),
                          8.w,
                          Flexible(
                            child: text(
                              text: controller.timeErrorMessage!,
                              size: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  8.h,
                  text(
                    text: 'Please select a time that allows at least 30 minutes of preparation before arrival.',
                    size: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.6),
                    textAlign: TextAlign.center,
                  ),
                  6.h,
                  text(
                    text: 'Restaurant Hours: 9:00 AM - 11:00 PM',
                    size: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
