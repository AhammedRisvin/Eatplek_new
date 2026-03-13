import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/order_confirmation_controller.dart';

class ResponsiveTimeSelectingWidget extends StatelessWidget {
  final OrderConfirmationController controller;
  final VoidCallback? onTimeChanged;

  const ResponsiveTimeSelectingWidget({
    super.key,
    required this.controller,
    this.onTimeChanged,
  });

  Widget _buildTimePickerButton({
    required String value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required ResponsiveHelper responsive,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            onIncrement();
            onTimeChanged?.call();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: responsive.spacing9,
              horizontal: responsive.spacing9,
            ),
            margin: EdgeInsets.only(bottom: responsive.spacing10),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(
                responsive.extraLargeBorderRadius,
              ),
              border: Border.all(color: AppColor.black.withOpacity(0.03)),
              boxShadow: [
                responsive.responsiveBoxShadow(
                  blurRadius: responsive.shadowBlurMedium,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_up_rounded,
                color: const Color(0XFF454545),
                size: responsive.iconSizeMedium,
              ),
            ),
          ),
        ),
        text(
          text: value,
          size: responsive.fontSize18,
          fontWeight: FontWeight.w400,
          color: AppColor.black,
        ),
        GestureDetector(
          onTap: () {
            onDecrement();
            onTimeChanged?.call();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: responsive.spacing9,
              horizontal: responsive.spacing9,
            ),
            margin: EdgeInsets.only(top: responsive.spacing10),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(
                responsive.extraLargeBorderRadius,
              ),
              border: Border.all(color: AppColor.black.withOpacity(0.03)),
              boxShadow: [
                responsive.responsiveBoxShadow(
                  blurRadius: responsive.shadowBlurMedium,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: const Color(0XFF454545),
                size: responsive.iconSizeMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.containerPadding,
      margin: EdgeInsets.only(bottom: responsive.spacing10),
      decoration: responsive.responsiveContainer(),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.string(
                dineTimeCalender,
                width: responsive.iconSizeMedium,
                height: responsive.iconSizeMedium,
              ),
              SizedBox(width: responsive.spacing12),
              text(
                text: 'Select Your Dining Time',
                size: responsive.fontSize16,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          SizedBox(height: responsive.spacing30),

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
                    responsive: responsive,
                  ),
                  SizedBox(width: responsive.spacing24),
                  text(
                    text: ':',
                    size: responsive.fontSize20,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black,
                  ),
                  SizedBox(width: responsive.spacing24),

                  // Minute picker
                  _buildTimePickerButton(
                    value: controller.selectedMinute.toString().padLeft(2, '0'),
                    onIncrement: controller.incrementMinute,
                    onDecrement: controller.decrementMinute,
                    responsive: responsive,
                  ),
                  SizedBox(width: responsive.spacing24),
                  text(
                    text: ':',
                    size: responsive.fontSize20,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black,
                  ),
                  SizedBox(width: responsive.spacing24),

                  // AM/PM picker
                  _buildTimePickerButton(
                    value: controller.selectedPeriod,
                    onIncrement: controller.togglePeriod,
                    onDecrement: controller.togglePeriod,
                    responsive: responsive,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: responsive.spacing30),

          GetBuilder<OrderConfirmationController>(
            id: 'time_widget',
            builder: (controller) {
              return Column(
                children: [
                  text(
                    text: 'Selected Time: ${controller.getFormattedTime()}',
                    size: responsive.fontSize16,
                    fontWeight: FontWeight.w600,
                    color:
                        controller.timeErrorMessage != null
                            ? Colors.red
                            : AppColor.appPrimary,
                  ),

                  if (controller.timeErrorMessage != null) ...[
                    SizedBox(height: responsive.spacing8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.spacing12,
                        vertical: responsive.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          responsive.inputBorderRadius,
                        ),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: responsive.iconSizeSmall,
                            color: Colors.red,
                          ),
                          SizedBox(width: responsive.spacing8),
                          Flexible(
                            child: text(
                              text: controller.timeErrorMessage!,
                              size: responsive.fontSize13,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: responsive.spacing8),
                  text(
                    text:
                        'Please select a time that allows at least 30 minutes of preparation before arrival.',
                    size: responsive.fontSize14,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.6),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsive.spacing6),
                  text(
                    text: 'Restaurant Hours: 9:00 AM - 11:00 PM',
                    size: responsive.fontSize12,
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
