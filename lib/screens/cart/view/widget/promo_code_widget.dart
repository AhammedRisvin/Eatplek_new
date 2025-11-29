import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controller/cart_controller.dart';

class PromoCodeWidget extends StatelessWidget {
  const PromoCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      id: 'promo_validation',
      builder: (controller) {
        return Container(
          width: context.wp(100),
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
                  SvgPicture.string(promoCodeSvg),
                  10.w,
                  Expanded(
                    child: buildCommonTextFormField(
                      hintText: 'Enter promo code',
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      controller: controller.promoCodeController,
                      context: context,
                      borderColor: controller.promoCodeError.isNotEmpty ? Colors.red : AppColor.transparent,
                      bgColor: AppColor.transparent,
                      isFromPhoneText: true,
                      onChanged: (value) => controller.formatPromoCode(value),
                    ),
                  ),
                  if (controller.appliedPromoCode.isNotEmpty)
                    GestureDetector(
                      onTap: controller.removePromoCode,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.close, size: 16, color: Colors.red),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.couponsView);
                      },
                      child: CircleAvatar(
                        radius: context.hp(2),
                        backgroundColor: AppColor.appPrimary,
                        child: Icon(Icons.arrow_forward_ios_rounded, color: AppColor.white, size: 18),
                      ),
                    ),
                ],
              ),
              if (controller.promoCodeError.isNotEmpty) ...[
                8.h,
                Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: text(
                    text: controller.promoCodeError,
                    size: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                8.h,
              ] else if (controller.appliedPromoCode.isNotEmpty) ...[
                8.h,
                Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: text(
                    text: 'Promo code applied successfully!',
                    size: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                8.h,
              ],
            ],
          ),
        );
      },
    );
  }
}
