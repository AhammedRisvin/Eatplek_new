import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/assets.dart';
import '../../controller/order_confirmation_controller.dart';

class NumberOfGuestWidget extends StatelessWidget {
  final OrderConfirmationController controller;

  const NumberOfGuestWidget({super.key, required this.controller});

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
              SvgPicture.string(personSvg),
              12.w,
              text(text: 'Number of Guests', size: 16, fontWeight: FontWeight.w500),
            ],
          ),
          16.h,
          buildCommonTextFormField(
            hintText: 'Enter number of guests',
            hintTextColor: Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            controller: controller.guestCountController,
            context: context,
            validator: controller.validateGuestCount,
            onChanged: controller.updateGuestCount,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
          ),
          12.h,
          text(
            text:
                'Minimum ${OrderConfirmationController.minGuests} guest, Maximum ${OrderConfirmationController.maxGuests} guests',
            size: 12,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
