import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../controller/order_confirmation_controller.dart';

class RestaurantWidgetFromOrders extends StatelessWidget {
  const RestaurantWidgetFromOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderConfirmationController>();

    // If vendor data is not available, show placeholder
    if (controller.vendor == null) {
      return _buildPlaceholder(context);
    }

    return Container(
      width: context.wp(100),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Row(
        children: [
          // ✅ Restaurant Image
          image(
            url: controller.vendor!.profileImage ?? 'https://picsum.photos/250?image=30',
            width: 83,
            height: 83,
            borderRadius: BorderRadius.circular(10),
          ),
          15.w,

          // ✅ Restaurant Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Name
                text(
                  text: controller.vendor!.name ?? 'Restaurant Name',
                  size: 16,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overFlow: TextOverflow.ellipsis,
                ),
                3.h,

                // Restaurant Location
                text(
                  text: controller.vendor!.place ?? 'Location not available',
                  size: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColor.black.withOpacity(0.6),
                  maxLines: 2,
                  overFlow: TextOverflow.ellipsis,
                ),
                6.h,

                // Operating Hours (Static)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.green),
                    4.w,
                    text(text: 'Open: 9:00 AM - 11:00 PM', size: 12, fontWeight: FontWeight.w500, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Placeholder widget when vendor data is not available
  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: context.wp(100),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: text(
            text: 'Restaurant information unavailable',
            size: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
