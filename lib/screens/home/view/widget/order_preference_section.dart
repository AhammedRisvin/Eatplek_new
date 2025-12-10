import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/home_controller.dart';

class OrderPreferenceSection extends StatelessWidget {
  final HomeController controller;

  const OrderPreferenceSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<HomeController>(
      id: HomeController.orderPreferenceId,
      builder: (controller) {
        return Container(
          width: responsive.screenWidth,
          padding: EdgeInsets.only(
            left: responsive.spacing20,
            right: responsive.spacing16,
            top: responsive.spacing20,
            bottom: responsive.spacing16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            color: AppColor.appPrimary.withOpacity(0.06),
          ),
          margin: EdgeInsets.only(top: responsive.spacing30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              text(
                text: 'Your Order Preference',
                size: responsive.fontSize16,
                fontWeight: FontWeight.w500,
                color: AppColor.black.withOpacity(0.6),
              ),
              SizedBox(height: responsive.spacing8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: text(
                      text: controller.orderPreference.isEmpty ? 'Select Preference' : controller.orderPreference,
                      size: responsive.fontSize18,
                      fontWeight: FontWeight.w500,
                      color: AppColor.appPrimary,
                    ),
                  ),
                  button(
                    name: 'Change',
                    width: responsive.smallButtonWidth,
                    height: responsive.buttonSmallHeight,
                    borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                    fontSize: responsive.fontSize12,
                    onTap: controller.onOrderPreferenceChanged,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
