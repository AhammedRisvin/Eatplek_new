import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../controller/restaurant_detail_view_controller.dart';

class CategorySection extends StatelessWidget {
  final RestaurantDetailViewController controller;

  const CategorySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader(responsive),
        SizedBox(height: responsive.spacing14),
        _buildCategoryTabs(responsive),
      ],
    );
  }

  Widget _buildCategoryHeader(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
      child: text(text: 'What would you like?', fontWeight: FontWeight.w600, size: responsive.fontSize18),
    );
  }

  Widget _buildCategoryTabs(ResponsiveHelper responsive) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'category_tabs',
      builder: (controller) {
        if (controller.categories.isEmpty) {
          return SizedBox();
        }

        return SizedBox(
          height: responsive.spacing50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final isSelected = controller.selectedCategoryIndex == index;

              return _buildCategoryTab(category, isSelected, () => controller.onCategoryTapped(index), responsive);
            },
            separatorBuilder: (context, index) => SizedBox(width: responsive.spacing10),
            itemCount: controller.categories.length,
          ),
        );
      },
    );
  }

  Widget _buildCategoryTab(String title, bool isSelected, VoidCallback onTap, ResponsiveHelper responsive) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: responsive.spacing11, vertical: responsive.spacing8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.appPrimary : Colors.grey[100],
          borderRadius: BorderRadius.circular(responsive.spacing40),
          border: Border.all(color: isSelected ? AppColor.appPrimary : Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            image(
              url: 'https://picsum.photos/250?image=20',
              height: responsive.spacing24,
              width: responsive.spacing24,
              borderRadius: BorderRadius.circular(responsive.spacing24),
            ),
            SizedBox(width: responsive.spacing10),
            text(
              text: title,
              size: responsive.fontSize14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColor.white : Colors.grey[700]!,
            ),
          ],
        ),
      ),
    );
  }
}
