import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
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
        SizedBox(height: responsive.spacing20),
        _buildVendorsGrid(responsive),
      ],
    );
  }

  /// Builds section header with title and view all button
  Widget _buildSectionHeader(ResponsiveHelper responsive) {
    return Padding(
      padding: responsive.horizontalPadding20,
      child: Row(
        children: [
          text(
            text: 'Delicious Options Around You',
            size: responsive.fontSize16,
            fontWeight: FontWeight.w600,
            color: AppColor.black,
          ),
          const Spacer(),
          button(
            name: 'View All',
            width: responsive.smallButtonWidth,
            height: responsive.buttonSmallHeight,
            borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            fontSize: responsive.fontSize12,
            fontWeight: FontWeight.w400,
            onTap: controller.onViewAllRestaurants,
            color: AppColor.appPrimary.withOpacity(0.1),
            borderColor: AppColor.appPrimary.withOpacity(0.1),
            textColor: AppColor.appPrimary,
          ),
        ],
      ),
    );
  }

  /// Builds the vendors grid with loading and empty states
  Widget _buildVendorsGrid(ResponsiveHelper responsive) {
    if (controller.isLoadingVendors && controller.vendors.isEmpty) {
      return _buildSkeletonGrid(responsive);
    }
    if (!controller.isLoadingVendors && !controller.hasError && controller.vendors.isEmpty) {
      return _buildEmptyState(responsive);
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
          final vendor = controller.vendors[index];
          return VendorCardWidget(vendor: vendor, onTap: () => controller.onRestaurantTapped(vendor));
        },
      ),
    );
  }

  /// Builds skeleton grid for loading state
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
          itemBuilder: (context, index) {
            return _buildSkeletonCard(responsive);
          },
        ),
      ),
    );
  }

  /// Builds individual skeleton card
  Widget _buildSkeletonCard(ResponsiveHelper responsive) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        color: Colors.grey[300],
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
                  color: Colors.grey[300],
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing8),
            child: Skeleton.leaf(child: Container(height: responsive.spacing12, color: Colors.grey[300])),
          ),
          SizedBox(height: responsive.spacing5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing8),
            child: Skeleton.leaf(
              child: Container(height: responsive.spacing10, width: responsive.spacing80, color: Colors.grey[300]),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds empty state when no vendors found
  Widget _buildEmptyState(ResponsiveHelper responsive) {
    return Padding(
      padding: responsive.horizontalPadding20,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: responsive.spacing40),
          child: Column(
            children: [
              Icon(Icons.restaurant_menu, size: responsive.iconSizeXL, color: Colors.grey[300]),
              SizedBox(height: responsive.spacing12),
              text(
                text: 'No vendors found',
                size: responsive.fontSize16,
                fontWeight: FontWeight.w500,
                color: AppColor.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
