import 'package:flutter/material.dart';

import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../controller/restaurant_detail_view_controller.dart';

class BannerSection extends StatelessWidget {
  final RestaurantDetailViewController controller;

  const BannerSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    if (controller.banners.isEmpty) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(left: responsive.spacing16, right: responsive.spacing16, top: responsive.spacing16),
      child: SizedBox(
        height: responsive.bannerHeight,
        child: PageView.builder(
          itemCount: controller.banners.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
              child: image(
                url: controller.banners[index],
                height: responsive.bannerHeight,
                width: responsive.screenWidth,
                borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
              ),
            );
          },
        ),
      ),
    );
  }
}
