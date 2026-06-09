import 'package:carousel_slider/carousel_slider.dart';
import 'package:eatplek_app/core/util/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../controller/home_controller.dart';

class BannerCarouselSection extends StatelessWidget {
  final HomeController controller;

  const BannerCarouselSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<HomeController>(
      init: controller,
      global: false,
      id: HomeController.carouselId,
      builder: (controller) {
        if (controller.isLoadingServices && controller.banners.isEmpty) {
          return _buildSkeleton(responsive);
        }
        if (controller.banners.isEmpty) return const SizedBox.shrink();
        if (controller.banners.length == 1) {
          return _buildSingleBanner(
            controller.banners.first.bannerImage ?? '',
            responsive,
          );
        }
        return _buildCarousel(controller, responsive);
      },
    );
  }

  Widget _buildCarousel(HomeController ctrl, ResponsiveHelper responsive) {
    return Column(
          children: [
            SizedBox(height: responsive.spacing20),
            CarouselSlider(
              options: CarouselOptions(
                height: responsive.bannerHeight,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 600),
                autoPlayCurve: Curves.easeInOutCubic,
                enlargeCenterPage: true,
                enlargeFactor: 0.04,
                viewportFraction: 1.0,
                onPageChanged: (index, _) => ctrl.updateCarouselIndex(index),
              ),
              items:
                  ctrl.banners.map((banner) {
                    return _buildBannerItem(
                      banner.bannerImage ?? '',
                      responsive,
                    );
                  }).toList(),
            ),
            SizedBox(height: responsive.spacing12),
            // Dot indicators
            GetBuilder<HomeController>(
              init: ctrl,
              global: false,
              id: HomeController.carouselId,
              builder:
                  (ctrl) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(ctrl.banners.length, (index) {
                      final isActive = ctrl.currentCarouselIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: EdgeInsets.symmetric(
                          horizontal: responsive.spacing3,
                        ),
                        width: isActive ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? AppColor.appPrimary
                                  : AppColor.appPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      );
                    }),
                  ),
            ),
          ],
        )
        .animate()
        .fade(duration: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildBannerItem(String imageUrl, ResponsiveHelper responsive) {
    return Container(
      width: responsive.screenWidth,
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColor.appPrimary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (_, _, _) => Container(
                color: AppColor.appPrimary.withOpacity(0.08),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColor.appPrimary.withOpacity(0.3),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildSingleBanner(String imageUrl, ResponsiveHelper responsive) {
    return Column(
          children: [
            SizedBox(height: responsive.spacing20),
            Container(
              width: responsive.screenWidth,
              height: responsive.bannerHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  responsive.largeBorderRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.appPrimary.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  responsive.largeBorderRadius,
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, _, _) => Container(
                        color: AppColor.appPrimary.withOpacity(0.08),
                      ),
                ),
              ),
            ),
          ],
        )
        .animate()
        .fade(duration: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildSkeleton(ResponsiveHelper responsive) {
    return Column(
      children: [
        SizedBox(height: responsive.spacing20),
        Skeletonizer(
          enabled: true,
          effect: ShimmerEffect(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            duration: const Duration(milliseconds: 1500),
          ),
          child: Skeleton.leaf(
            child: Container(
              width: responsive.screenWidth,
              height: responsive.bannerHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(
                  responsive.largeBorderRadius,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
