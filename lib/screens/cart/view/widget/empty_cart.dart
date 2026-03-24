import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          // Illustrated icon in circle
          Container(
                width: responsive.spacing100,
                height: responsive.spacing100,
                decoration: BoxDecoration(
                  color: AppColor.appPrimary.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: responsive.spacing50,
                  color: AppColor.appPrimary.withOpacity(0.45),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fade(duration: 400.ms),

          SizedBox(height: responsive.spacing24),

          text(
                text: 'Your Cart is Empty',
                size: responsive.fontSize20,
                fontWeight: FontWeight.w700,
                color: AppColor.black.withOpacity(0.75),
              )
              .animate()
              .fade(duration: 350.ms, delay: 150.ms)
              .slideY(begin: 0.2, end: 0, duration: 350.ms, delay: 150.ms),

          SizedBox(height: responsive.spacing8),

          text(
            text: 'Add some delicious food to get started',
            size: responsive.fontSize14,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.45),
            textAlign: TextAlign.center,
          ).animate().fade(duration: 350.ms, delay: 200.ms),

          SizedBox(height: responsive.spacing40),

          button(
                name: 'Browse Restaurants',
                width: responsive.screenWidth * 0.65,
                fontSize: responsive.fontSize15,
                height: responsive.buttonHeight,
                fontWeight: FontWeight.w600,
                borderRadius: BorderRadius.circular(responsive.spacing40),
                onTap: () => Get.back(),
              )
              .animate()
              .fade(duration: 350.ms, delay: 280.ms)
              .slideY(begin: 0.15, end: 0, duration: 350.ms, delay: 280.ms),
        ],
      ),
    );
  }
}
