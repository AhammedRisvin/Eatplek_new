import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
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
    return GetBuilder<RestaurantDetailViewController>(
      id: 'main_content',
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    _buildBackgroundImage(controller),
                    _buildCollapsibleAppBar(controller),
                    _buildMainContent(controller),
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

  Widget _buildBackgroundImage(RestaurantDetailViewController controller) {
    if (_isScrolled) return SizedBox();

    return Container(
      width: context.wp(100),
      height: 201,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            controller.banners.isNotEmpty ? controller.banners.first : 'https://picsum.photos/250?image=30',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildBackButton(),
                  10.w,
                  _buildRestaurantInfo(controller),
                  Spacer(),
                  Container(
                    height: context.hp(5),
                    width: context.hp(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColor.white.withOpacity(0.2),
                      border: Border.all(color: AppColor.white.withOpacity(0.4)),
                    ),
                    child: IconButton(onPressed: () => Get.back(), icon: Image.asset(mapPng)),
                  ),
                  10.w,
                  Container(
                    height: context.hp(5),
                    width: context.hp(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColor.white.withOpacity(0.2),
                      border: Border.all(color: AppColor.white.withOpacity(0.4)),
                    ),
                    child: IconButton(onPressed: () => Get.back(), icon: Image.asset(sharePng)),
                  ),
                ],
              ),
              30.h,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: context.hp(5),
        width: context.hp(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColor.white.withOpacity(0.4)),
        ),
        child: IconButton(onPressed: () => Navigator.of(context).pop(), icon: SvgPicture.string(arrowBack)),
      ),
    );
  }

  Widget _buildRestaurantInfo(RestaurantDetailViewController controller) {
    return Column(children: [text(text: 'Restaurant', color: AppColor.white, size: 20, fontWeight: FontWeight.w600)]);
  }

  Widget _buildCollapsibleAppBar(RestaurantDetailViewController controller) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: 0,
      left: 0,
      right: 0,
      height: _isScrolled ? 120 : 0,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: _isScrolled ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                controller.banners.isNotEmpty ? controller.banners.first : 'https://picsum.photos/250?image=30',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 30),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
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
                16.w,
                text(text: 'Restaurant', color: AppColor.white, size: 16, fontWeight: FontWeight.w600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(RestaurantDetailViewController controller) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: _isScrolled ? 120 : 100,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.scaffoldColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
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
                  _buildErrorState(controller)
                else if (controller.isLoading)
                  // Loading skeleton
                  _buildLoadingSkeleton()
                else if (controller.restaurantData.isEmpty)
                  // Empty state
                  _buildEmptyState()
                else ...[
                  // Banner Section
                  BannerSection(controller: controller),
                  20.h,

                  // Category Section
                  CategorySection(controller: controller),
                  20.h,

                  // Food Grid Section
                  FoodGridSection(controller: controller),
                  SizedBox(height: 100), // Bottom padding for cart bar
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(RestaurantDetailViewController controller) {
    return SizedBox(
      height: context.hp(80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColor.black.withOpacity(0.3)),
            24.h,
            text(text: 'Oops! Something went wrong', size: 18, fontWeight: FontWeight.w600, color: AppColor.black),
            12.h,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: text(
                text: controller.errorMessage,
                size: 14,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.6),
                textAlign: TextAlign.center,
              ),
            ),
            32.h,
            button(
              name: 'Try Again',
              onTap: () {
                if (controller.restaurantId != null) {
                  controller.getRestaurantDetailsFn(restaurantId: controller.restaurantId!);
                }
              },
              width: 150,
              height: 50,
              color: AppColor.appPrimary,
              textColor: AppColor.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              borderRadius: BorderRadius.circular(100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner skeleton
        Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            height: 180,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
          ),
        ),
        20.h,
        // Category header skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 24,
            width: 150,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
          ),
        ),
        14.h,
        // Category tabs skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, _) => 10.w,
              itemBuilder:
                  (_, _) => Container(
                    width: 100,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(40)),
                  ),
            ),
          ),
        ),
        20.h,
        // Food grid skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: Get.height * 0.00098,
            ),
            itemCount: 6,
            itemBuilder:
                (_, _) => Container(
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                ),
          ),
        ),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: context.hp(80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: AppColor.black.withOpacity(0.3)),
            24.h,
            text(text: 'No items available', size: 18, fontWeight: FontWeight.w600, color: AppColor.black),
            12.h,
            text(
              text: 'This restaurant has no food items available right now',
              size: 14,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
