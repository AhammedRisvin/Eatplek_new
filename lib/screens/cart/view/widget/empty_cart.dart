import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: AppColor.black.withOpacity(0.3)),
          20.h,
          text(
            text: 'Your Cart is Empty',
            size: 24,
            fontWeight: FontWeight.w600,
            color: AppColor.black.withOpacity(0.7),
          ),
          10.h,
          text(
            text: 'Add some delicious food to get started',
            size: 16,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.5),
          ),
          40.h,
          button(
            name: 'Browse Menu',
            width: context.wp(60),
            fontSize: 16,
            height: 50,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(100),
            onTap: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
