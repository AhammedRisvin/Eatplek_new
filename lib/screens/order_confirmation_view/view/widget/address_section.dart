import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/assets.dart';
import '../../controller/order_confirmation_controller.dart';

class AddressWidget extends StatelessWidget {
  final OrderConfirmationController controller;

  const AddressWidget({super.key, required this.controller});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.string(locationSvg),
              10.w,
              text(text: 'Delivery Address', size: 16, fontWeight: FontWeight.w500),
            ],
          ),
          20.h,

          // Full Name Field
          buildCommonTextFormField(
            hintText: 'Full Name',
            hintTextColor: Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            controller: controller.fullNameController,
            context: context,
            validator: controller.validateFullName,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          10.h,

          // Phone Number Field
          buildCommonTextFormField(
            hintText: 'Phone Number',
            hintTextColor: Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            controller: controller.phoneController,
            context: context,
            validator: controller.validatePhoneNumber,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),

            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          ),
          10.h,

          // Address Field
          buildCommonTextFormField(
            hintText: 'Enter Full Address',
            hintTextColor: Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            controller: controller.addressController,
            context: context,
            validator: controller.validateAddress,
            minLine: 4,
            hintTextSize: 16,
            contentPadding: EdgeInsets.only(left: 16, top: 12, right: 10, bottom: 12),
            textAlignVertical: TextAlignVertical.top,
          ),
          12.h,
          text(
            text: 'Your order will be delivered to this address.',
            size: 12,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
