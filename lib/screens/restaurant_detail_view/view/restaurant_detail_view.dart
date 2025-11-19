import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/screens/restaurant_detail_view/controller/restaurant_detail_view_controller.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/util/app_color.dart';
import '../../../core/util/assets.dart';
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
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(children: [_buildBackgroundImage(), _buildCollapsibleAppBar(), _buildMainContent()]),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    if (_isScrolled) return SizedBox();

    return Container(
      width: context.wp(100),
      height: 201,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage('https://picsum.photos/250?image=30'), fit: BoxFit.cover),
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
                  _buildRestaurantInfo(),
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

  Widget _buildRestaurantInfo() {
    return Column(
      children: [text(text: 'Nibraz Restaurant', color: AppColor.white, size: 20, fontWeight: FontWeight.w600)],
    );
  }

  Widget _buildCollapsibleAppBar() {
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
            image: DecorationImage(image: NetworkImage('https://picsum.photos/250?image=30'), fit: BoxFit.cover),
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
                text(text: 'Nibraz Restaurant', color: AppColor.white, size: 16, fontWeight: FontWeight.w600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
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
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.h,
              _buildCategoryHeader(),
              14.h,
              _buildCategoryTabs(),
              20.h,
              _buildFoodGrid(),
              SizedBox(height: 100),
            ],
          ),
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

  Widget _buildCategoryTabs() {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'category_tabs',
      builder: (controller) {
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

  Widget _buildFoodGrid() {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'food_grid',
      builder: (controller) {
        if (controller.filteredFoodItems.isEmpty) {
          return _buildEmptyState();
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
            itemCount: controller.filteredFoodItems.length,
            itemBuilder: (context, index) {
              return FoodWidget(foodItem: controller.filteredFoodItems[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
