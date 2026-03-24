import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: text(
            text: 'What would you like?',
            fontWeight: FontWeight.w700,
            size: responsive.fontSize16,
            color: AppColor.black,
          ),
        ),
        SizedBox(height: responsive.spacing12),
        _buildTabs(responsive),
      ],
    );
  }

  Widget _buildTabs(ResponsiveHelper responsive) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'category_tabs',
      builder: (controller) {
        if (controller.categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: responsive.spacing48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
            physics: const BouncingScrollPhysics(),
            itemCount: controller.categories.length,
            separatorBuilder: (_, _) => SizedBox(width: responsive.spacing8),
            itemBuilder: (context, index) {
              final isSelected = controller.selectedCategoryIndex == index;
              return _buildTab(
                label: controller.categories[index],
                isSelected: isSelected,
                index: index,
                onTap: () => controller.onCategoryTapped(index),
                responsive: responsive,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required int index,
    required VoidCallback onTap,
    required ResponsiveHelper responsive,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing14,
              vertical: responsive.spacing8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.appPrimary : AppColor.white,
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
              border: Border.all(
                color:
                    isSelected
                        ? AppColor.appPrimary
                        : AppColor.black.withOpacity(0.1),
                width: 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: AppColor.appPrimary.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                        ),
                      ],
            ),
            child: text(
              text: label,
              size: responsive.fontSize13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color:
                  isSelected
                      ? AppColor.white
                      : AppColor.black.withOpacity(0.65),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 40 * index))
        .fade(duration: 250.ms)
        .slideX(begin: 0.1, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }
}
