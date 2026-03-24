import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/home_controller.dart';
import 'restaurant_card_widget.dart';

class VendorGridSection extends StatelessWidget {
  final HomeController controller;

  const VendorGridSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Column(
      children: [
        SizedBox(height: responsive.spacing20),
        _buildSectionHeader(responsive),
        SizedBox(height: responsive.spacing16),
        _buildContent(responsive),
      ],
    );
  }

  Widget _buildSectionHeader(ResponsiveHelper responsive) {
    return Padding(
      padding: responsive.horizontalPadding20,
      child: Row(
        children: [
          Container(
            width: responsive.spacing4,
            height: responsive.spacing18,
            margin: EdgeInsets.only(right: responsive.spacing8),
            decoration: BoxDecoration(
              color: AppColor.appPrimary,
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            ),
          ),
          text(
            text: 'Restaurants Near You',
            size: responsive.fontSize16,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
          ),
          const Spacer(),
          GestureDetector(
            onTap: controller.onViewAllRestaurants,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.spacing12,
                vertical: responsive.spacing6,
              ),
              decoration: BoxDecoration(
                color: AppColor.appPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(
                  responsive.largeBorderRadius,
                ),
              ),
              child: text(
                text: 'View All',
                size: responsive.fontSize12,
                fontWeight: FontWeight.w600,
                color: AppColor.appPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ResponsiveHelper responsive) {
    if (controller.isLoadingVendors && controller.vendors.isEmpty) {
      return _buildSkeletonGrid(responsive);
    }

    if (!controller.isLoadingVendors &&
        !controller.hasError &&
        controller.vendors.isEmpty) {
      return emptyState(
        icon: Icons.restaurant_menu_rounded,
        title: 'No restaurants found',
        subtitle: 'Try changing your location or order preference.',
      );
    }

    return Padding(
      padding: responsive.horizontalPadding20,
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.gridCrossAxisCount,
          mainAxisSpacing: responsive.gridMainAxisSpacing,
          crossAxisSpacing: responsive.gridCrossAxisSpacing,
          childAspectRatio: responsive.gridChildAspectRatio,
        ),
        itemCount: controller.vendors.length,
        itemBuilder: (context, index) {
          return VendorCardWidget(
                vendor: controller.vendors[index],
                onTap:
                    () => controller.onRestaurantTapped(
                      controller.vendors[index],
                    ),
              )
              .animate()
              .fade(duration: 350.ms, delay: (index * 50).ms)
              .slideY(
                begin: 0.2,
                end: 0,
                duration: 350.ms,
                delay: (index * 50).ms,
                curve: Curves.easeOut,
              );
        },
      ),
    );
  }

  Widget _buildSkeletonGrid(ResponsiveHelper responsive) {
    return Padding(
      padding: responsive.horizontalPadding20,
      child: Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          duration: const Duration(milliseconds: 1500),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: responsive.gridCrossAxisCount,
            mainAxisSpacing: responsive.gridMainAxisSpacing,
            crossAxisSpacing: responsive.gridCrossAxisSpacing,
            childAspectRatio: responsive.gridChildAspectRatio,
          ),
          itemCount: 6,
          itemBuilder: (_, _) => _buildSkeletonCard(responsive),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(ResponsiveHelper responsive) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Skeleton.leaf(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(responsive.cardBorderRadius),
                    topRight: Radius.circular(responsive.cardBorderRadius),
                  ),
                  color: Colors.grey.shade200,
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing10),
            child: Skeleton.leaf(
              child: Container(
                height: responsive.spacing12,
                color: Colors.grey.shade200,
              ),
            ),
          ),
          SizedBox(height: responsive.spacing6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing10),
            child: Skeleton.leaf(
              child: Container(
                height: responsive.spacing10,
                width: responsive.spacing80,
                color: Colors.grey.shade200,
              ),
            ),
          ),
          SizedBox(height: responsive.spacing10),
        ],
      ),
    );
  }
}
