import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';

class WaitingFormConfirmationSheet extends StatelessWidget {
  const WaitingFormConfirmationSheet({super.key, required this.selectedPaymentMethod});

  final dynamic selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.wp(100),
      padding: const EdgeInsets.only(left: 16.0, right: 16, top: 10, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 120,
              height: 4,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Color(0XFFD9D9D9), borderRadius: BorderRadius.circular(100)),
            ),
          ),
          30.h,
          image(url: selectedPaymentMethod['imageUrl'], width: 80, height: 80, borderRadius: BorderRadius.circular(10)),
          30.h,
          text(text: 'Waiting for Confirmation...', size: 22, fontWeight: FontWeight.w600, color: AppColor.black),
          10.h,
          text(
            text:
                '''Please wait 2-3 minutes for the restaurant to confirm your order. You can stay here or go to the Order page to track your order status.''',
            size: 16,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.4),
            textAlign: TextAlign.center,
          ),
          30.h,
          button(
            name: 'Go to My Orders',
            width: context.wp(100),
            height: 50,
            borderRadius: BorderRadius.circular(100),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            onTap: () {
              Get.toNamed(Routes.orderSuccessView);
            },
          ),
          10.h,
        ],
      ),
    );
  }
}
