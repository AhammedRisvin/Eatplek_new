import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: responsive.spacing80, color: AppColor.black.withOpacity(0.3)),
          SizedBox(height: responsive.spacing20),
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: responsive.fontSize24,
              fontWeight: FontWeight.w600,
              color: AppColor.black.withOpacity(0.7),
            ),
          ),
          SizedBox(height: responsive.spacing10),
          Text(
            'Add some delicious food to get started',
            style: TextStyle(
              fontSize: responsive.fontSize16,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.5),
            ),
          ),
          SizedBox(height: responsive.spacing40),
          button(
            name: 'Browse Menu',
            width: responsive.screenWidth * 0.6,
            fontSize: responsive.fontSize16,
            height: responsive.spacing50,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(responsive.spacing40),
            onTap: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
