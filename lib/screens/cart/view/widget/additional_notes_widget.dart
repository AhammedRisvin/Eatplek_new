import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controller/cart_controller.dart';

class AdditionalNotesWidget extends StatelessWidget {
  const AdditionalNotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<CartController>(
      id: 'instructions_validation',
      builder: (controller) {
        return Container(
          width: responsive.screenWidth,
          padding: EdgeInsets.symmetric(vertical: responsive.spacing20, horizontal: responsive.spacing20),
          margin: EdgeInsets.only(bottom: responsive.spacing20),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            border: Border.all(color: AppColor.black.withOpacity(0.03)),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.05),
                blurRadius: responsive.spacing24,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.string(additionalNotesSvg),
                  SizedBox(width: responsive.spacing10),
                  Text(
                    'Additional Notes',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: responsive.fontSize16, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing20),
              buildCommonTextFormField(
                hintText: 'Write your instructions here (optional)',
                hintTextColor: const Color(0XFF1D1D1D).withOpacity(0.6),
                borderColor: controller.instructionsError.isNotEmpty ? Colors.red : AppColor.black.withOpacity(0.1),
                bgColor: AppColor.white,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                controller: controller.instructionsController,
                context: context,
                minLine: 4,
                hintTextSize: responsive.fontSize13,
                contentPadding: EdgeInsets.only(
                  left: responsive.spacing16,
                  top: responsive.spacing12,
                  right: responsive.spacing10,
                  bottom: 0,
                ),
                textAlignVertical: TextAlignVertical.top,
                onChanged: (value) {
                  controller.clearInstructionsError();
                },
              ),
              if (controller.instructionsError.isNotEmpty) ...[
                SizedBox(height: responsive.spacing8),
                Text(
                  controller.instructionsError,
                  style: TextStyle(fontSize: responsive.fontSize12, color: Colors.red, fontWeight: FontWeight.w400),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
