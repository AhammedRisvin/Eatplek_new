import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/order_confirmation_controller.dart';

class ResponsiveRestaurantWidget extends StatelessWidget {
  final OrderConfirmationController controller;

  const ResponsiveRestaurantWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    // If vendor data is not available, show placeholder
    if (controller.vendor == null) {
      return _buildPlaceholder(responsive);
    }

    return Container(
      width: responsive.widthPercent(100),
      padding: EdgeInsets.symmetric(vertical: responsive.spacing14, horizontal: responsive.spacing15),
      margin: EdgeInsets.only(bottom: responsive.spacing10),
      decoration: responsive.responsiveContainer(),
      child: Row(
        children: [
          // ✅ Restaurant Image
          image(
            url: controller.vendor!.profileImage ?? 'https://picsum.photos/250?image=30',
            width: responsive.restaurantImageSize,
            height: responsive.restaurantImageSize,
            borderRadius: BorderRadius.circular(responsive.inputBorderRadius),
          ),
          SizedBox(width: responsive.spacing15),

          // ✅ Restaurant Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Name
                text(
                  text: controller.vendor!.name ?? 'Restaurant Name',
                  size: responsive.fontSize16,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overFlow: TextOverflow.ellipsis,
                ),
                SizedBox(height: responsive.spacing3),

                // Restaurant Location
                text(
                  text: controller.vendor!.place ?? 'Location not available',
                  size: responsive.fontSize14,
                  fontWeight: FontWeight.w400,
                  color: AppColor.black.withOpacity(0.6),
                  maxLines: 2,
                  overFlow: TextOverflow.ellipsis,
                ),
                SizedBox(height: responsive.spacing6),

                // Operating Hours (Static)
                Row(
                  children: [
                    Icon(Icons.access_time, size: responsive.iconSizeSmall, color: Colors.green),
                    SizedBox(width: responsive.spacing4),
                    text(
                      text: 'Open: 9:00 AM - 11:00 PM',
                      size: responsive.fontSize12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
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
  Widget _buildPlaceholder(ResponsiveHelper responsive) {
    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.containerPadding,
      margin: EdgeInsets.only(bottom: responsive.spacing10),
      decoration: responsive.responsiveContainer(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: responsive.spacing20),
          child: text(
            text: 'Restaurant information unavailable',
            size: responsive.fontSize14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
