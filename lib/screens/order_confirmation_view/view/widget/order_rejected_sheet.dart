import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/app_color.dart';

class OrderRejectedSheet extends StatelessWidget {
  const OrderRejectedSheet({super.key, required this.selectedPaymentMethod});

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
          text(text: 'Order Rejected', size: 22, fontWeight: FontWeight.w600, color: AppColor.black),
          10.h,
          text(
            text: '''Unfortunately, the restaurant has rejected your order. Please try another restaurant.''',
            size: 16,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.4),
            textAlign: TextAlign.center,
          ),
          12.h,
          Container(
            width: context.wp(100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColor.black.withOpacity(0.1)),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                text(text: 'Rejected Reason', size: 16, fontWeight: FontWeight.w600),
                6.h,
                text(
                  text:
                      'reason for te rejecting order is the miss match of the idea behind the order that made a confusion so our chef could not follow the instruction completely so the order we going to reject ',
                  size: 13,
                  fontWeight: FontWeight.w300,
                  color: AppColor.black.withOpacity(0.4),
                ),
              ],
            ),
          ),
          30.h,
          button(
            name: 'Order Again',
            width: context.wp(100),
            height: 50,
            borderRadius: BorderRadius.circular(100),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            onTap: () {},
          ),
          10.h,
        ],
      ),
    );
  }
}
