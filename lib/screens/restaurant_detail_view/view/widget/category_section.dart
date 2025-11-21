import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';

class CategorySection extends StatelessWidget {
  final RestaurantDetailViewController controller;

  const CategorySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildCategoryHeader(), 14.h, _buildCategoryTabs()],
    );
  }

  Widget _buildCategoryHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: text(text: 'What would you like?', fontWeight: FontWeight.w600, size: 18),
    );
  }

  Widget _buildCategoryTabs() {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'category_tabs',
      builder: (controller) {
        if (controller.categories.isEmpty) {
          return SizedBox();
        }

        return SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final isSelected = controller.selectedCategoryIndex == index;

              return _buildCategoryTab(category, isSelected, () => controller.onCategoryTapped(index));
            },
            separatorBuilder: (context, index) => 10.w,
            itemCount: controller.categories.length,
          ),
        );
      },
    );
  }

  Widget _buildCategoryTab(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.appPrimary : Colors.grey[100],
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: isSelected ? AppColor.appPrimary : Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            image(
              url: 'https://picsum.photos/250?image=20',
              height: 24,
              width: 24,
              borderRadius: BorderRadius.circular(100),
            ),
            10.w,
            text(
              text: title,
              size: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColor.white : Colors.grey[700]!,
            ),
          ],
        ),
      ),
    );
  }
}
