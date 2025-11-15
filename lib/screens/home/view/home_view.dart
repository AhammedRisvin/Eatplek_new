import 'package:carousel_slider/carousel_slider.dart';
import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controller/home_controller.dart';
import 'widget/restaurant_card_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      // ✅ REMOVED: init: HomeController() - Already initialized in main.dart
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              // Static App Bar
              _buildAppBar(controller),
              // Scrollable Content
              Expanded(
                child: GetBuilder<HomeController>(
                  id: HomeController.restaurantsId,
                  builder: (controller) {
                    // Show error screen if there's an error
                    if (controller.hasError && controller.restaurants.isEmpty) {
                      return _buildErrorScreen(controller);
                    }

                    return SingleChildScrollView(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          20.h,
                          _buildCarouselSection(controller),
                          _buildOrderPreferenceSection(controller),
                          _buildRestaurantsSection(controller),
                          // Show loading indicator at bottom if loading more
                          if (controller.isLoadingMore)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: _buildLoadingMoreIndicator(),
                            ),
                          100.h, // Bottom padding
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(HomeController controller) {
    return Container(
      padding: EdgeInsets.only(top: Get.mediaQuery.padding.top + 20, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(),
      child: Row(
        children: [
          Expanded(child: _buildUserGreeting(controller)),
          10.w,
          _buildIconButton(searchSvg, controller.onSearchTapped),
          10.w,
          _buildIconButton(bellSvg, controller.onNotificationTapped),
        ],
      ),
    );
  }

  Widget _buildUserGreeting(HomeController controller) {
    return GetBuilder<HomeController>(
      id: HomeController.userGreetingId,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                text(text: 'Hello,', size: 26, fontWeight: FontWeight.w600, color: AppColor.appPrimary),
                10.w,
                text(
                  text: '${controller.userName}  👋,',
                  size: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
            5.h,
            Row(
              children: [
                text(text: controller.userCity, size: 14, fontWeight: FontWeight.w300, color: AppColor.black),
                10.w,
                GestureDetector(
                  onTap: controller.onLocationChangeTapped,
                  child: text(text: 'Change', size: 10, fontWeight: FontWeight.w600, color: AppColor.appPrimary),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(String svgString, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.black.withOpacity(0.1), width: 1),
        ),
        child: Center(child: SvgPicture.string(svgString)),
      ),
    );
  }

  Widget _buildCarouselSection(HomeController controller) {
    return GetBuilder<HomeController>(
      id: HomeController.carouselId,
      builder: (controller) {
        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  controller.updateCarouselIndex(index);
                },
              ),
              items:
                  controller.carouselImages.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: Get.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.12),
                                spreadRadius: 0,
                                blurRadius: 14,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(child: Icon(Icons.error, color: Colors.grey)),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderPreferenceSection(HomeController controller) {
    return GetBuilder<HomeController>(
      id: HomeController.orderPreferenceId,
      builder: (controller) {
        return Container(
          width: Get.width,
          padding: const EdgeInsets.only(left: 20, right: 16, top: 20, bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.appPrimary.withOpacity(0.06),
          ),
          margin: const EdgeInsets.only(bottom: 20, top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(
                text: 'Your Order Preference',
                size: 16,
                fontWeight: FontWeight.w500,
                color: AppColor.black.withOpacity(0.6),
              ),
              8.h,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  text(
                    text: controller.orderPreference.isEmpty ? 'Select Preference' : controller.orderPreference,
                    size: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColor.appPrimary,
                  ),
                  button(
                    name: 'Change',
                    width: 80,
                    height: 30,
                    borderRadius: BorderRadius.circular(20),
                    fontSize: 14,
                    onTap: controller.onOrderPreferenceChanged,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestaurantsSection(HomeController controller) {
    return Column(children: [_buildSectionHeader(controller), 23.h, _buildRestaurantsGrid(controller)]);
  }

  Widget _buildSectionHeader(HomeController controller) {
    return Row(
      children: [
        text(text: 'Delicious Options Around You', size: 18, fontWeight: FontWeight.w600, color: AppColor.black),
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

  Widget _buildRestaurantsGrid(HomeController controller) {
    // Show skeleton loading
    if (controller.isLoadingRestaurants && controller.restaurants.isEmpty) {
      return _buildSkeletonGrid();
    }

    // Show empty state
    if (!controller.isLoadingRestaurants && !controller.hasError && controller.restaurants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.restaurant_menu, size: 60, color: Colors.grey[300]),
              12.h,
              text(
                text: 'No restaurants found',
                size: 16,
                fontWeight: FontWeight.w500,
                color: AppColor.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
      );
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
      itemCount: controller.restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = controller.restaurants[index];
        return RestaurantCardWidget(restaurant: restaurant, onTap: () => controller.onRestaurantTapped(restaurant));
      },
    );
  }

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
        itemCount: 6, // Show 6 skeleton cards
        itemBuilder: (context, index) {
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
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
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.appPrimary),
                  ),
                ),
                12.w,
                text(
                  text: 'Loading more...',
                  size: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(HomeController controller) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            20.h,
            _buildCarouselSection(controller),
            _buildOrderPreferenceSection(controller),
            // Error content takes remaining space
            SizedBox(
              height: Get.height * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: AppColor.redColor),
                  20.h,
                  text(
                    text: 'Oops! Something went wrong',
                    size: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                    textAlign: TextAlign.center,
                  ),
                  12.h,
                  text(
                    text:
                        controller.errorMessage.isEmpty
                            ? 'Unable to fetch restaurants. Please try again.'
                            : controller.errorMessage,
                    size: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.6),
                    textAlign: TextAlign.center,
                  ),
                  30.h,
                  button(
                    name: 'Retry',
                    width: 120,
                    height: 45,
                    borderRadius: BorderRadius.circular(12),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    onTap: controller.retryFetchingRestaurants,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
