import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:eatplek_app/screens/home/view/widget/restaurant_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/routes/routes.dart';
import '../controller/search_controller.dart';

class SearchVendorView extends StatelessWidget {
  const SearchVendorView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<SearchVendorController>(
      init: SearchVendorController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.scaffoldColor,
          appBar: _buildAppBar(controller, responsive),
          body: Column(
            children: [
              // ── Search + Filter Bar ──
              GetBuilder<SearchVendorController>(
                id: SearchVendorController.headerId,
                builder: (controller) {
                  return _buildHeaderSection(controller, responsive);
                },
              ),

              // ── Vendors Grid ──
              Expanded(
                child: GetBuilder<SearchVendorController>(
                  id: SearchVendorController.vendorsId,
                  builder: (controller) {
                    return _buildBody(controller, responsive);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    SearchVendorController controller,
    ResponsiveHelper responsive,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColor.scaffoldColor,
      centerTitle: true,
      leadingWidth: 80,
      title: text(
        text: 'Explore Vendors',
        size: responsive.fontSize18,
        fontWeight: FontWeight.w600,
      ),
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.white,
              border: Border.all(
                color: Colors.black.withOpacity(0.06),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: SvgPicture.string(arrowBack2),
          ),
        ),
      ),
    );
  }

  // ─── Header: Search + Service chip + Sort ────────────────────────────────

  Widget _buildHeaderSection(
    SearchVendorController controller,
    ResponsiveHelper responsive,
  ) {
    return Container(
      color: AppColor.scaffoldColor,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing20,
        vertical: responsive.spacing12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          _buildSearchField(controller, responsive),
          SizedBox(height: responsive.spacing12),

          // Service type chip + Sort chips in one scrollable row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Service type chip
                _buildServiceChip(controller, responsive),
                SizedBox(width: responsive.spacing8),

                // Divider
                Container(
                  width: 1,
                  height: 24,
                  color: AppColor.black.withOpacity(0.12),
                  margin: EdgeInsets.symmetric(horizontal: responsive.spacing4),
                ),
                SizedBox(width: responsive.spacing8),

                // Sort chips
                _buildSortChip(
                  controller: controller,
                  responsive: responsive,
                  label: 'Nearest',
                  value: 'distance',
                  icon: Icons.near_me_rounded,
                ),
                SizedBox(width: responsive.spacing8),
                _buildSortChip(
                  controller: controller,
                  responsive: responsive,
                  label: 'Top Rated',
                  value: 'rating',
                  icon: Icons.star_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    SearchVendorController controller,
    ResponsiveHelper responsive,
  ) {
    return Container(
      height: responsive.spacing48,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        border: Border.all(color: AppColor.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchTextController,
        onChanged: controller.onSearchChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: responsive.fontSize14,
          color: AppColor.black,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Search restaurants...',
          hintStyle: TextStyle(
            fontSize: responsive.fontSize14,
            color: AppColor.black.withOpacity(0.4),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(13),
            child: SvgPicture.string(
              searchSvg,
              color: AppColor.black.withOpacity(0.4),
              width: 20,
              height: 20,
            ),
          ),
          suffixIcon:
              controller.searchKeyword.isNotEmpty
                  ? GestureDetector(
                    onTap: controller.clearSearch,
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColor.black.withOpacity(0.5),
                      size: 20,
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: responsive.spacing12),
        ),
      ),
    );
  }

  Widget _buildServiceChip(
    SearchVendorController controller,
    ResponsiveHelper responsive,
  ) {
    return GestureDetector(
      onTap: controller.onServiceTypeChipTapped,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing12,
          vertical: responsive.spacing6,
        ),
        decoration: BoxDecoration(
          color: AppColor.appPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
          border: Border.all(
            color: AppColor.appPrimary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            text(
              text:
                  controller.serviceLabel.isEmpty
                      ? 'Service'
                      : controller.serviceLabel,
              size: responsive.fontSize12,
              fontWeight: FontWeight.w600,
              color: AppColor.appPrimary,
            ),
            SizedBox(width: responsive.spacing4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColor.appPrimary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip({
    required SearchVendorController controller,
    required ResponsiveHelper responsive,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = controller.selectedSort == value;

    return GestureDetector(
      onTap: () => controller.onSortSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing12,
          vertical: responsive.spacing6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.appPrimary : AppColor.white,
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
          border: Border.all(
            color:
                isSelected
                    ? AppColor.appPrimary
                    : AppColor.black.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color:
                  isSelected ? AppColor.white : AppColor.black.withOpacity(0.6),
            ),
            SizedBox(width: responsive.spacing4),
            text(
              text: label,
              size: responsive.fontSize12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color:
                  isSelected ? AppColor.white : AppColor.black.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody(
    SearchVendorController controller,
    ResponsiveHelper responsive,
  ) {
    if (controller.isLoading && controller.vendors.isEmpty) {
      return _buildSkeletonGrid(responsive);
    }

    if (controller.hasError && controller.vendors.isEmpty) {
      return _buildErrorState(controller, responsive);
    }

    if (!controller.isLoading && controller.vendors.isEmpty) {
      return _buildEmptyState(controller, responsive);
    }

    return _buildVendorGrid(controller, responsive);
  }

  Widget _buildVendorGrid(
    SearchVendorController controller,
    ResponsiveHelper responsive,
  ) {
    return SingleChildScrollView(
      controller: controller.scrollController,
      padding: EdgeInsets.all(responsive.spacing20),
      child: Column(
        children: [
          GridView.builder(
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
              return VendorCardWidget(
                vendor: vendor,
                onTap: () {
                  // Navigate to restaurant detail — same as home
                  Get.toNamed(Routes.restaurantDetail, arguments: vendor);
                },
              );
            },
          ),

          // Loading more indicator
          if (controller.isLoadingMore) ...[
            SizedBox(height: responsive.spacing20),
            _buildLoadingMoreIndicator(responsive),
          ],

          SizedBox(height: responsive.spacing100),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(ResponsiveHelper responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: responsive.spacing16,
          height: responsive.spacing16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.appPrimary),
          ),
        ),
        SizedBox(width: responsive.spacing12),
        text(
          text: 'Loading more...',
          size: responsive.fontSize14,
          fontWeight: FontWeight.w400,
          color: AppColor.black.withOpacity(0.5),
        ),
      ],
    );
  }

  // ─── Skeleton ─────────────────────────────────────────────────────────────

  Widget _buildSkeletonGrid(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.all(responsive.spacing20),
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
            child: Skeleton.leaf(
              child: Container(
                height: responsive.spacing12,
                color: Colors.grey[300],
              ),
            ),
          ),
          SizedBox(height: responsive.spacing5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing8),
            child: Skeleton.leaf(
              child: Container(
                height: responsive.spacing10,
                width: responsive.spacing80,
                color: Colors.grey[300],
              ),
            ),
          ),
          SizedBox(height: responsive.spacing10),
        ],
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(
    SearchVendorController controller,
    ResponsiveHelper responsive,
  ) {
    final bool isSearching = controller.searchKeyword.isNotEmpty;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.restaurant_menu_rounded,
              size: responsive.iconSizeXL,
              color: Colors.grey[300],
            ),
            SizedBox(height: responsive.spacing16),
            text(
              text:
                  isSearching
                      ? 'No results for "${controller.searchKeyword}"'
                      : 'No vendors available',
              size: responsive.fontSize16,
              fontWeight: FontWeight.w600,
              color: AppColor.black.withOpacity(0.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing8),
            text(
              text:
                  isSearching
                      ? 'in ${controller.serviceLabel} · ${_cityHint(controller)}'
                      : 'No vendors found for ${controller.serviceLabel} in your area.',
              size: responsive.fontSize13,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.4),
              textAlign: TextAlign.center,
            ),
            if (isSearching) ...[
              SizedBox(height: responsive.spacing20),
              button(
                name: 'Clear Search',
                width: responsive.smallButtonWidth + 40,
                height: responsive.buttonSmallHeight,
                borderRadius: BorderRadius.circular(
                  responsive.largeBorderRadius,
                ),
                fontSize: responsive.fontSize13,
                fontWeight: FontWeight.w600,
                onTap: controller.clearSearch,
                color: AppColor.appPrimary.withOpacity(0.1),
                borderColor: AppColor.appPrimary.withOpacity(0.3),
                textColor: AppColor.appPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────────────────

  Widget _buildErrorState(
    SearchVendorController controller,
    ResponsiveHelper responsive,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: responsive.iconSizeXL,
              color: Colors.grey[300],
            ),
            SizedBox(height: responsive.spacing16),
            text(
              text: 'Something went wrong',
              size: responsive.fontSize16,
              fontWeight: FontWeight.w600,
              color: AppColor.black.withOpacity(0.6),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing8),
            text(
              text: controller.errorMessage,
              size: responsive.fontSize13,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing20),
            button(
              name: 'Try Again',
              width: responsive.smallButtonWidth,
              height: responsive.buttonHeight,
              borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
              fontSize: responsive.fontSize14,
              fontWeight: FontWeight.w600,
              onTap: controller.retryFetch,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _cityHint(SearchVendorController controller) {
    // Best effort — show coordinates rounded if no city available
    return '(${controller.userLatitude.toStringAsFixed(2)}, ${controller.userLongitude.toStringAsFixed(2)})';
  }
}
