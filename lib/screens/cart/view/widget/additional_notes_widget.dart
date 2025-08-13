import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controller/cart_controller.dart';

class AdditionalNotesWidget extends StatelessWidget {
  const AdditionalNotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      id: 'instructions_validation',
      builder: (controller) {
        return Container(
          width: context.wp(100),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          margin: EdgeInsets.only(bottom: 20),
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
                  SvgPicture.string(additionalNotesSvg),
                  10.w,
                  text(text: 'Additional Notes', fontWeight: FontWeight.w500, size: 16),
                ],
              ),
              20.h,
              buildCommonTextFormField(
                hintText: 'Write your instructions here (optional)',
                hintTextColor: Color(0XFF1D1D1D).withOpacity(0.6),
                borderColor: controller.instructionsError.isNotEmpty ? Colors.red : AppColor.black.withOpacity(0.1),
                bgColor: AppColor.white,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                controller: controller.instructionsController,
                context: context,
                minLine: 4,
                hintTextSize: 13,
                contentPadding: EdgeInsets.only(left: 16, top: 12, right: 10, bottom: 0),
                textAlignVertical: TextAlignVertical.top,
                onChanged: (value) {
                  controller.clearInstructionsError();
                },
              ),
              if (controller.instructionsError.isNotEmpty) ...[
                8.h,
                text(text: controller.instructionsError, size: 12, color: Colors.red, fontWeight: FontWeight.w400),
              ],
            ],
          ),
        );
      },
    );
  }
}
