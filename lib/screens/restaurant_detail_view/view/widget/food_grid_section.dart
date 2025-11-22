import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import 'food_widget.dart';

class FoodGridSection extends StatelessWidget {
  final RestaurantDetailViewController controller;

  const FoodGridSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'food_grid',
      builder: (controller) {
        final filteredFoodItems = controller.getFilteredFoodItems();

        if (filteredFoodItems.isEmpty) {
          return _buildEmptyCategoryState();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: Get.height * 0.00085,
            ),
            itemCount: filteredFoodItems.length,
            itemBuilder: (context, index) {
              return FoodWidget(foodItem: filteredFoodItems[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyCategoryState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 48, color: AppColor.black.withOpacity(0.3)),
            16.h,
            text(
              text: 'No items available in this category',
              size: 16,
              fontWeight: FontWeight.w500,
              color: AppColor.black.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
