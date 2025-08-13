import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/assets.dart';
import '../../controller/order_confirmation_controller.dart';

class DeliveryDateCalender extends StatelessWidget {
  const DeliveryDateCalender({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderConfirmationController>();

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
              SvgPicture.string(locationSvg),
              12.w,
              text(text: 'Choose Your Delivery Date', size: 16, fontWeight: FontWeight.w500),
            ],
          ),
          10.h,
          buildCommonTextFormField(
            hintText: 'Select Date',
            hintTextColor: Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.none,
            textInputAction: TextInputAction.next,
            controller: controller.deliveryDateController,
            context: context,
            readOnly: true,
            suffixIcon: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.string(dineTimeCalender, color: AppColor.black),
            ),
            validator: controller.validateDeliveryDate,
            onTap: () {
              controller.showCalendarDialog();
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          10.h,
          text(
            text: 'Select the most convenient day to get your order delivered fresh and on time.',
            fontWeight: FontWeight.w400,
            size: 12,
            color: AppColor.black.withOpacity(0.6),
            decorationStyle: TextDecorationStyle.wavy,
          ),
        ],
      ),
    );
  }
}
