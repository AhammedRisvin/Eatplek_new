import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../home/controller/home_controller.dart';
import '../../../home/view/widget/restaurant_card_widget.dart';

class MultipleBranchBottomSheet extends StatelessWidget {
  const MultipleBranchBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.wp(100),
      // Set maximum height for the bottom sheet
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
      ),
      padding: const EdgeInsets.only(left: 16.0, right: 16, top: 10, bottom: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            6.h,
            text(text: 'Available Branches Nearby', size: 18, fontWeight: FontWeight.w600, color: AppColor.black),
            6.h,
            text(
              text: 'We found multiple branches of this restaurant within your selected location radius.',
              size: 14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
            ),
            12.h,
            Divider(color: AppColor.black.withOpacity(0.06), thickness: 1),
            12.h,
            text(
              text: 'Please choose your preferred branch to continue your order.',
              size: 14,
              fontWeight: FontWeight.w300,
              color: AppColor.black.withOpacity(0.6),
            ),
            20.h,
            _buildRestaurantsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantsGrid() {
    return GetBuilder<HomeController>(
      id: HomeController.restaurantsId,
      init: HomeController(),
      builder: (controller) {
        if (controller.isLoadingRestaurants) {
          return const Center(child: CircularProgressIndicator());
        }

        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: Get.height * 0.001,
          ),
          itemCount: controller.restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = controller.restaurants[index];
            return RestaurantCardWidget(restaurant: restaurant, onTap: () => controller.onRestaurantTapped(restaurant));
          },
        );
      },
    );
  }
}
