import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/order_confirmation_controller.dart';

class ResponsiveAddressWidget extends StatefulWidget {
  final OrderConfirmationController controller;

  const ResponsiveAddressWidget({super.key, required this.controller});

  @override
  State<ResponsiveAddressWidget> createState() => _ResponsiveAddressWidgetState();
}

class _ResponsiveAddressWidgetState extends State<ResponsiveAddressWidget> {
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.containerPadding,
      margin: EdgeInsets.only(bottom: responsive.spacing10),
      decoration: responsive.responsiveContainer(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Section Header
          Row(
            children: [
              SvgPicture.string(locationSvg, width: responsive.iconSizeSmall, height: responsive.iconSizeSmall),
              SizedBox(width: responsive.spacing10),
              text(text: 'Delivery Details', size: responsive.fontSize16, fontWeight: FontWeight.w600),
            ],
          ),
          SizedBox(height: responsive.spacing20),

          // ✅ FULL NAME FIELD
          text(
            text: 'Full Name *',
            size: responsive.fontSize13,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.8),
          ),
          SizedBox(height: responsive.spacing6),
          buildCommonTextFormField(
            hintText: 'Enter your full name',
            hintTextColor: const Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            controller: widget.controller.fullNameController,
            context: context,
            validator: widget.controller.validateFullName,
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.formFieldPaddingHorizontal,
              vertical: responsive.formFieldPaddingVertical,
            ),
          ),
          SizedBox(height: responsive.spacing16),

          // ✅ PHONE NUMBER FIELD
          text(
            text: 'Phone Number *',
            size: responsive.fontSize13,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.8),
          ),
          SizedBox(height: responsive.spacing6),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing12,
                  vertical: responsive.formFieldPaddingVertical,
                ),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  border: Border.all(color: AppColor.black.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
                ),
                child: text(text: '+91', size: responsive.fontSize14, fontWeight: FontWeight.w500),
              ),
              SizedBox(width: responsive.spacing8),
              Expanded(
                child: buildCommonTextFormField(
                  hintText: '10-digit number',
                  hintTextColor: const Color(0XFF1D1D1D).withOpacity(0.6),
                  borderColor: AppColor.black.withOpacity(0.1),
                  bgColor: AppColor.white,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  controller: widget.controller.phoneController,
                  context: context,
                  validator: widget.controller.validatePhoneNumber,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive.formFieldPaddingHorizontal,
                    vertical: responsive.formFieldPaddingVertical,
                  ),
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing16),

          // ✅ ADDRESS FIELD
          text(
            text: 'Delivery Address *',
            size: responsive.fontSize13,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.8),
          ),
          SizedBox(height: responsive.spacing6),
          buildCommonTextFormField(
            hintText: 'Enter complete address (street, building, flat number)',
            hintTextColor: const Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            controller: widget.controller.addressController,
            context: context,
            validator: widget.controller.validateAddress,
            minLine: 3,
            maxLine: 5,
            hintTextSize: responsive.fontSize13,
            contentPadding: EdgeInsets.only(
              left: responsive.spacing14,
              top: responsive.spacing12,
              right: responsive.spacing14,
              bottom: responsive.spacing12,
            ),
            textAlignVertical: TextAlignVertical.top,
          ),
          SizedBox(height: responsive.spacing12),
          text(
            text: '✓ Your order will be delivered to this address',
            size: responsive.fontSize12,
            fontWeight: FontWeight.w400,
            color: Colors.green,
          ),
          SizedBox(height: responsive.spacing16),

          // ✅ GUEST COUNT FIELD (Optional but shown for restaurant orders)
          text(
            text: 'Number of Guests',
            size: responsive.fontSize13,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.8),
          ),
          SizedBox(height: responsive.spacing6),
          buildCommonTextFormField(
            hintText: 'Enter number of guests (1-30)',
            hintTextColor: const Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            controller: widget.controller.guestCountController,
            context: context,
            validator: widget.controller.validateGuestCount,
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.formFieldPaddingHorizontal,
              vertical: responsive.formFieldPaddingVertical,
            ),
            onChanged: (value) => widget.controller.updateGuestCount(value),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
          ),
        ],
      ),
    );
  }
}
