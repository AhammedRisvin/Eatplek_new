import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';

class BannerSection extends StatelessWidget {
  final RestaurantDetailViewController controller;

  const BannerSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.banners.isEmpty) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: SizedBox(
        height: 180,
        child: PageView.builder(
          itemCount: controller.banners.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: image(
                url: controller.banners[index],
                height: 180,
                width: context.wp(100),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }
}
