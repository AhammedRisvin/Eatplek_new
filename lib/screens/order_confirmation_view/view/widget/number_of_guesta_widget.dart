import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/order_confirmation_controller.dart';

class ResponsiveNumberOfGuestWidget extends StatelessWidget {
  final OrderConfirmationController controller;

  const ResponsiveNumberOfGuestWidget({super.key, required this.controller});

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
              SvgPicture.string(personSvg, width: responsive.iconSizeSmall, height: responsive.iconSizeSmall),
              SizedBox(width: responsive.spacing12),
              text(text: 'Number of Guests', size: responsive.fontSize16, fontWeight: FontWeight.w500),
            ],
          ),
          SizedBox(height: responsive.spacing16),

          // ✅ Guest Count Input Field
          buildCommonTextFormField(
            hintText: 'Enter number of guests',
            hintTextColor: const Color(0XFF1D1D1D).withOpacity(0.6),
            borderColor: AppColor.black.withOpacity(0.1),
            bgColor: AppColor.white,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            controller: controller.guestCountController,
            context: context,
            validator: controller.validateGuestCount,
            onChanged: controller.updateGuestCount,
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.formFieldPaddingHorizontal,
              vertical: responsive.formFieldPaddingVertical,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
          ),
          SizedBox(height: responsive.spacing12),

          // ✅ Guest Range Information
          text(
            text:
                'Minimum ${OrderConfirmationController.minGuests} guest, Maximum ${OrderConfirmationController.maxGuests} guests',
            size: responsive.fontSize12,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
