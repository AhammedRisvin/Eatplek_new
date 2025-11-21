import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
import '../../../core/util/common_widgets.dart';
import '../controller/restaurant_detail_view_controller.dart';
import 'widget/food_widget.dart';

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
          body: SizedBox(
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
        child: IconButton(onPressed: () => Get.back(), icon: SvgPicture.string(arrowBack)),
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
      top: _isScrolled ? 120 - 20 : 120 - 20,
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
                  // Banners carousel
                  if (controller.banners.isNotEmpty) _buildBanners(controller),
                  20.h,
                  _buildCategoryHeader(),
                  14.h,
                  _buildCategoryTabs(controller),
                  20.h,
                  _buildFoodGrid(controller),
                  SizedBox(height: 100),
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
              separatorBuilder: (_, __) => 10.w,
              itemBuilder:
                  (_, __) => Container(
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
                (_, __) => Container(
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

  Widget _buildBanners(RestaurantDetailViewController controller) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: SizedBox(
        height: 180,
        child: PageView.builder(
          itemCount: controller.banners.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: image(
                url: controller.banners[index],
                height: 180,
                width: context.wp(100),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: text(text: 'What would you like?', fontWeight: FontWeight.w600, size: 18),
    );
  }

  Widget _buildCategoryTabs(RestaurantDetailViewController controller) {
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

  Widget _buildFoodGrid(RestaurantDetailViewController controller) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'food_grid',
      builder: (controller) {
        final filteredFoodItems = controller.getFilteredFoodItems();

        if (filteredFoodItems.isEmpty) {
          return _buildEmptyCategoryState();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: Get.height * 0.00098,
            ),
            itemCount: filteredFoodItems.length,
            itemBuilder: (context, index) {
              return FoodWidget(foodItem: filteredFoodItems[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyCategoryState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 48, color: AppColor.black.withOpacity(0.3)),
            16.h,
            text(
              text: 'No items available in this category',
              size: 16,
              fontWeight: FontWeight.w500,
              color: AppColor.black.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
