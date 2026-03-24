import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        final items = controller.getFilteredFoodItems();

        if (items.isEmpty) {
          return emptyState(
            icon: Icons.no_food_rounded,
            title: 'No items in this category',
            subtitle: 'Try a different category above.',
          );
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
            itemCount: items.length,
            itemBuilder:
                (context, index) =>
                    FoodWidget(foodItem: items[index], animationIndex: index),
          ),
        );
      },
    );
  }
}
