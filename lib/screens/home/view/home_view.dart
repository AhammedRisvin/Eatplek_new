import 'package:carousel_slider/carousel_slider.dart';
import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import 'widget/restaurant_card_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              // Static App Bar
              _buildAppBar(controller),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      20.h,
                      _buildCarouselSection(controller),
                      _buildOrderPreferenceSection(controller),
                      _buildRestaurantsSection(controller),
                      100.h, // Bottom padding
                    ],
                  ),
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
                text(text: controller.userLocation, size: 14, fontWeight: FontWeight.w300, color: AppColor.black),
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
                    text: controller.orderPreference,
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
    return GetBuilder<HomeController>(
      id: HomeController.restaurantsId,
      builder: (controller) {
        if (controller.isLoadingRestaurants) {
          return const Center(child: CircularProgressIndicator());
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
      },
    );
  }
}

// Example of how to use specific updates in other parts of your app:
// To update only carousel: Get.find<HomeController>().update([HomeController.carouselId]);
// To update only restaurants: Get.find<HomeController>().update([HomeController.restaurantsId]);
// To update only user greeting: Get.find<HomeController>().update([HomeController.userGreetingId]);
// To update only order preference: Get.find<HomeController>().update([HomeController.orderPreferenceId]);

// Don't forget to register the controller in your main.dart or binding
// Get.put(HomeController());
