import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import 'food_widget.dart';

class FoodGridSection extends StatelessWidget {
  final RestaurantDetailViewController controller;

  const FoodGridSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<RestaurantDetailViewController>(
      id: 'food_grid',
      builder: (controller) {
        final filteredFoodItems = controller.getFilteredFoodItems();

        if (filteredFoodItems.isEmpty) {
          return _buildEmptyCategoryState(responsive);
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.gridCrossAxisCount,
              mainAxisSpacing: responsive.gridMainAxisSpacing,
              crossAxisSpacing: responsive.gridCrossAxisSpacing,
              childAspectRatio: responsive.gridChildAspectRatioForFood,
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

  Widget _buildEmptyCategoryState(ResponsiveHelper responsive) {
    return SizedBox(
      height: responsive.spacing200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: responsive.iconSizeLarge, color: AppColor.black.withOpacity(0.3)),
            SizedBox(height: responsive.spacing16),
            text(
              text: 'No items available in this category',
              size: responsive.fontSize16,
              fontWeight: FontWeight.w500,
              color: AppColor.black.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
