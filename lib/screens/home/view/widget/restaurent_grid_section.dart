import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controller/home_controller.dart';
import 'restaurant_card_widget.dart';

class VendorGridSection extends StatelessWidget {
  final HomeController controller;

  const VendorGridSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(children: [20.h, _buildSectionHeader(), 20.h, _buildVendorsGrid()]);
  }

  /// Builds section header with title and view all button
  Widget _buildSectionHeader() {
    return Row(
      children: [
        text(text: 'Delicious Options Around You', size: 16, fontWeight: FontWeight.w600, color: AppColor.black),
        const Spacer(),
        button(
          name: 'View All',
          width: 80,
          height: 30,
          borderRadius: BorderRadius.circular(30),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          onTap: controller.onViewAllRestaurants,
          color: AppColor.appPrimary.withOpacity(0.1),
          borderColor: AppColor.appPrimary.withOpacity(0.1),
          textColor: AppColor.appPrimary,
        ),
      ],
    );
  }

  /// Builds the vendors grid with loading and empty states
  Widget _buildVendorsGrid() {
    if (controller.isLoadingVendors && controller.vendors.isEmpty) {
      return _buildSkeletonGrid();
    }
    if (!controller.isLoadingVendors && !controller.hasError && controller.vendors.isEmpty) {
      return _buildEmptyState();
    }
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: Get.height * 0.001,
      ),
      itemCount: controller.vendors.length,
      itemBuilder: (context, index) {
        final vendor = controller.vendors[index];
        return VendorCardWidget(vendor: vendor, onTap: () => controller.onRestaurantTapped(vendor));
      },
    );
  }

  /// Builds skeleton grid for loading state
  Widget _buildSkeletonGrid() {
    return Skeletonizer(
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
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: Get.height * 0.001,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildSkeletonCard();
        },
      ),
    );
  }

  /// Builds individual skeleton card
  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[300]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Skeleton.leaf(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  color: Colors.grey[300],
                ),
              ),
            ),
          ),
          10.h,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Skeleton.leaf(child: Container(height: 12, color: Colors.grey[300])),
          ),
          5.h,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Skeleton.leaf(child: Container(height: 10, width: 80, color: Colors.grey[300])),
          ),
        ],
      ),
    );
  }

  /// Builds empty state when no vendors found
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.restaurant_menu, size: 60, color: Colors.grey[300]),
            12.h,
            text(
              text: 'No vendors found',
              size: 16,
              fontWeight: FontWeight.w500,
              color: AppColor.black.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
