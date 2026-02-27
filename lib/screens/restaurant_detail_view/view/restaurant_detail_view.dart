import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../../../core/util/responsive_helper.dart';
import '../controller/restaurant_detail_view_controller.dart';
import 'widget/banner_section.dart';
import 'widget/bottom_cart_bar.dart';
import 'widget/category_section.dart';
import 'widget/food_grid_section.dart';

class RestaurantDetailView extends StatefulWidget {
  const RestaurantDetailView({super.key});

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _initializeScrollListener();
  }

  void _initializeScrollListener() {
    _scrollController.addListener(() {
      const double scrollThreshold = 100;
      final bool shouldBeScrolled = _scrollController.offset > scrollThreshold;

      if (shouldBeScrolled != _isScrolled) {
        setState(() {
          _isScrolled = shouldBeScrolled;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<RestaurantDetailViewController>(
      id: 'main_content',
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: responsive.screenHeight,
                width: responsive.screenWidth,
                child: Stack(
                  children: [
                    _buildBackgroundImage(controller, responsive),
                    _buildCollapsibleAppBar(controller, responsive),
                    _buildMainContent(controller, responsive),
                  ],
                ),
              ),
              // Bottom cart bar overlay
              Positioned(bottom: 0, left: 0, right: 0, child: BottomCartBar()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundImage(
    RestaurantDetailViewController controller,
    ResponsiveHelper responsive,
  ) {
    if (_isScrolled) return SizedBox();

    return Container(
      width: responsive.screenWidth,
      height: responsive.spacing201,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/restaurantBg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildBackButton(responsive),
                  SizedBox(width: responsive.spacing10),
                  _buildRestaurantInfo(responsive),
                  Spacer(),
                  Container(
                    height: responsive.iconSizeLarge,
                    width: responsive.iconSizeLarge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColor.white.withOpacity(0.2),
                      border: Border.all(
                        color: AppColor.white.withOpacity(0.4),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        log('map pressed');
                      },
                      icon: Image.asset(mapPng),
                    ),
                  ),
                  SizedBox(width: responsive.spacing10),
                  Container(
                    height: responsive.iconSizeLarge,
                    width: responsive.iconSizeLarge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColor.white.withOpacity(0.2),
                      border: Border.all(
                        color: AppColor.white.withOpacity(0.4),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        log('share pressed');
                      },
                      icon: Image.asset(sharePng),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(ResponsiveHelper responsive) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: responsive.iconSizeLarge,
        width: responsive.iconSizeLarge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColor.white.withOpacity(0.4)),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: SvgPicture.string(arrowBack),
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo(ResponsiveHelper responsive) {
    return Column(
      children: [
        text(
          text: 'Restaurant',
          color: AppColor.white,
          size: responsive.fontSize20,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildCollapsibleAppBar(
    RestaurantDetailViewController controller,
    ResponsiveHelper responsive,
  ) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: 0,
      left: 0,
      right: 0,
      height: _isScrolled ? responsive.spacing120 : 0,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: _isScrolled ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/restaurantBg.png'),
              // image: NetworkImage(
              //   controller.banners.isNotEmpty
              //       ? controller.banners.first
              //       : 'https://picsum.photos/250?image=30',
              // ),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: responsive.spacing16,
              right: responsive.spacing16,
              top: responsive.spacing30,
            ),
            child: Row(
              children: [
                Container(
                  height: responsive.spacing40,
                  width: responsive.spacing40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColor.white.withOpacity(0.4)),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Get.back(),
                    icon: SvgPicture.string(arrowBack),
                  ),
                ),
                SizedBox(width: responsive.spacing16),
                text(
                  text: 'Restaurant',
                  color: AppColor.white,
                  size: responsive.fontSize16,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    RestaurantDetailViewController controller,
    ResponsiveHelper responsive,
  ) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: _isScrolled ? responsive.spacing120 : responsive.spacing100,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.scaffoldColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(responsive.largeBorderRadius),
            topRight: Radius.circular(responsive.largeBorderRadius),
          ),
        ),
        child: Skeletonizer(
          enabled: controller.isLoading,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error state
                if (controller.hasError)
                  _buildErrorState(controller, responsive)
                else if (controller.isLoading)
                  // Loading skeleton
                  _buildLoadingSkeleton(responsive)
                else if (controller.restaurantData.isEmpty)
                  // Empty state
                  _buildEmptyState(responsive)
                else ...[
                  // Banner Section
                  BannerSection(controller: controller),
                  SizedBox(height: responsive.spacing20),

                  // Category Section
                  CategorySection(controller: controller),
                  SizedBox(height: responsive.spacing20),

                  // Food Grid Section
                  FoodGridSection(controller: controller),
                  SizedBox(
                    height: responsive.spacing100,
                  ), // Bottom padding for cart bar
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    RestaurantDetailViewController controller,
    ResponsiveHelper responsive,
  ) {
    return SizedBox(
      height: responsive.heightPercent(80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: responsive.iconSizeXL,
              color: AppColor.black.withOpacity(0.3),
            ),
            SizedBox(height: responsive.spacing24),
            text(
              text: 'Oops! Something went wrong',
              size: responsive.fontSize18,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
            ),
            SizedBox(height: responsive.spacing12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.spacing32),
              child: text(
                text: controller.errorMessage,
                size: responsive.fontSize14,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.6),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: responsive.spacing32),
            button(
              name: 'Try Again',
              onTap: () {
                if (controller.restaurantId != null) {
                  controller.getRestaurantDetailsFn(
                    restaurantId: controller.restaurantId!,
                  );
                }
              },
              width: responsive.spacing150,
              height: responsive.spacing50,
              color: AppColor.appPrimary,
              textColor: AppColor.white,
              fontWeight: FontWeight.w600,
              fontSize: responsive.fontSize16,
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner skeleton
        Padding(
          padding: EdgeInsets.all(responsive.spacing16),
          child: Container(
            height: responsive.spacing180,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            ),
          ),
        ),
        SizedBox(height: responsive.spacing20),
        // Category header skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: Container(
            height: responsive.spacing24,
            width: responsive.spacing150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(responsive.spacing8),
            ),
          ),
        ),
        SizedBox(height: responsive.spacing14),
        // Category tabs skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: SizedBox(
            height: responsive.spacing50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, _) => SizedBox(width: responsive.spacing10),
              itemBuilder:
                  (_, _) => Container(
                    width: responsive.spacing100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(responsive.spacing40),
                    ),
                  ),
            ),
          ),
        ),
        SizedBox(height: responsive.spacing20),
        // Food grid skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.gridCrossAxisCount,
              mainAxisSpacing: responsive.gridMainAxisSpacing,
              crossAxisSpacing: responsive.gridCrossAxisSpacing,
              childAspectRatio: responsive.gridChildAspectRatio,
            ),
            itemCount: 6,
            itemBuilder:
                (_, _) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(
                      responsive.largeBorderRadius,
                    ),
                  ),
                ),
          ),
        ),
        SizedBox(height: responsive.spacing100),
      ],
    );
  }

  Widget _buildEmptyState(ResponsiveHelper responsive) {
    return SizedBox(
      height: responsive.heightPercent(80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: responsive.iconSizeXL,
              color: AppColor.black.withOpacity(0.3),
            ),
            SizedBox(height: responsive.spacing24),
            text(
              text: 'No items available',
              size: responsive.fontSize18,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
            ),
            SizedBox(height: responsive.spacing12),
            text(
              text: 'This restaurant has no food items available right now',
              size: responsive.fontSize14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
