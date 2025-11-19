import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';

class OrderPreferenceSection extends StatelessWidget {
  final HomeController controller;

  const OrderPreferenceSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: HomeController.orderPreferenceId,
      builder: (controller) {
        return Container(
          width: Get.width,
          padding: const EdgeInsets.only(left: 20, right: 16, top: 20, bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.appPrimary.withOpacity(0.06),
          ),
          margin: const EdgeInsets.only(bottom: 20, top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              text(
                text: 'Your Order Preference',
                size: 16,
                fontWeight: FontWeight.w500,
                color: AppColor.black.withOpacity(0.6),
              ),
              8.h,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: text(
                      text: controller.orderPreference.isEmpty ? 'Select Preference' : controller.orderPreference,
                      size: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColor.appPrimary,
                    ),
                  ),
                  button(
                    name: 'Change',
                    width: 80,
                    height: 30,
                    borderRadius: BorderRadius.circular(20),
                    fontSize: 12,
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
