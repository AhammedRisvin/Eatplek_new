import 'package:eatplek_app/screens/order_details_view/model/order_details_model.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/assets.dart';
import '../../../../core/util/common_widgets.dart';
import '../../controller/order_details_controller.dart';

class RestaurantAndOrderInfoSection extends StatelessWidget {
  final OrderDetailsModel order;
  final VoidCallback onCallTap;
  final VoidCallback onMessageTap;

  const RestaurantAndOrderInfoSection({
    super.key,
    required this.order,
    required this.onCallTap,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03), width: 1),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(text: 'Restaurant & Order Info', size: 18, fontWeight: FontWeight.w600),
          18.h,
          Row(
            children: [
              image(url: order.restaurant.imageUrl, width: 50, height: 50, borderRadius: BorderRadius.circular(10)),
              14.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      text: order.restaurant.name,
                      size: 14,
                      fontWeight: FontWeight.w500,
                      maxLines: 2,
                      overFlow: TextOverflow.ellipsis,
                    ),
                    4.h,
                    text(
                      text: order.restaurant.address,
                      size: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.black.withOpacity(0.4),
                      maxLines: 2,
                      overFlow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onMessageTap,
                child: Container(padding: const EdgeInsets.all(8), child: SvgPicture.string(messageSvg)),
              ),
              GestureDetector(
                onTap: onCallTap,
                child: Container(padding: const EdgeInsets.all(8), child: SvgPicture.string(callSvg)),
              ),
            ],
          ),
          20.h,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(text: 'Order ID', size: 14, fontWeight: FontWeight.w400, color: AppColor.black.withOpacity(0.6)),
              text(text: order.orderId, size: 14, fontWeight: FontWeight.w500, color: AppColor.black),
            ],
          ),
          14.h,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(
                text: 'Order Date & Time',
                size: 14,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.6),
              ),
              GetBuilder<OrderDetailsController>(
                builder:
                    (controller) => text(
                      text: controller.getFormattedOrderDateTime(),
                      size: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.black,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
