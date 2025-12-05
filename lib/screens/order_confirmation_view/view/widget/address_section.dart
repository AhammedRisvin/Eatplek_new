import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/assets.dart';
import '../../controller/order_confirmation_controller.dart';

class AddressWidget extends StatefulWidget {
  final OrderConfirmationController controller;

  const AddressWidget({super.key, required this.controller});

  @override
  State<AddressWidget> createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
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
          // ✅ Section Header
          Row(
            children: [
              SvgPicture.string(locationSvg),
              10.w,
              text(text: 'Delivery Details', size: 16, fontWeight: FontWeight.w600),
            ],
          ),
          20.h,

          // ✅ FULL NAME FIELD
          text(text: 'Full Name *', size: 13, fontWeight: FontWeight.w500, color: AppColor.black.withOpacity(0.8)),
          6.h,
          buildCommonTextFormField(
            hintText: 'Enter your full name',
            hintTextColor: Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            controller: widget.controller.fullNameController,
            context: context,
            validator: widget.controller.validateFullName,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          16.h,

          // ✅ PHONE NUMBER FIELD
          text(text: 'Phone Number *', size: 13, fontWeight: FontWeight.w500, color: AppColor.black.withOpacity(0.8)),
          6.h,
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  border: Border.all(color: AppColor.black.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: text(text: '+91', size: 14, fontWeight: FontWeight.w500),
              ),
              8.w,
              Expanded(
                child: buildCommonTextFormField(
                  hintText: '10-digit number',
                  hintTextColor: Color(0XFF1D1D1D).withOpacity(0.6),
                  borderColor: AppColor.black.withOpacity(0.1),
                  bgColor: AppColor.white,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  controller: widget.controller.phoneController,
                  context: context,
                  validator: widget.controller.validatePhoneNumber,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                ),
              ),
            ],
          ),
          16.h,

          // ✅ ADDRESS FIELD
          text(
            text: 'Delivery Address *',
            size: 13,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.8),
          ),
          6.h,
          buildCommonTextFormField(
            hintText: 'Enter complete address (street, building, flat number)',
            hintTextColor: Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            controller: widget.controller.addressController,
            context: context,
            validator: widget.controller.validateAddress,
            minLine: 3,
            maxLine: 5,
            hintTextSize: 13,
            contentPadding: EdgeInsets.only(left: 14, top: 12, right: 14, bottom: 12),
            textAlignVertical: TextAlignVertical.top,
          ),
          12.h,
          text(
            text: '✓ Your order will be delivered to this address',
            size: 12,
            fontWeight: FontWeight.w400,
            color: Colors.green,
          ),
          16.h,

          // ✅ GUEST COUNT FIELD (Optional but shown for restaurant orders)
          text(text: 'Number of Guests', size: 13, fontWeight: FontWeight.w500, color: AppColor.black.withOpacity(0.8)),
          6.h,
          buildCommonTextFormField(
            hintText: 'Enter number of guests (1-30)',
            hintTextColor: Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            controller: widget.controller.guestCountController,
            context: context,
            validator: widget.controller.validateGuestCount,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onChanged: (value) => widget.controller.updateGuestCount(value),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
          ),
        ],
      ),
    );
  }
}
