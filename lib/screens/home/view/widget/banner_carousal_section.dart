import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
      id: HomeController.carouselId,
      builder: (controller) {
        if (controller.isLoadingServices && controller.banners.isEmpty) {
          return _buildCarouselSkeleton(responsive);
        }
        if (controller.banners.isEmpty) {
          return const SizedBox.shrink();
        }
        if (controller.banners.length == 1) {
          return _buildSingleBanner(controller.banners.first.bannerImage ?? '', responsive);
        }
        return _buildCarousel(controller, responsive);
      },
    );
  }

  /// Builds carousel for multiple banners
  Widget _buildCarousel(HomeController controller, ResponsiveHelper responsive) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: responsive.bannerHeight,
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
              controller.banners.map((banner) {
                return Builder(
                  builder: (BuildContext context) {
                    return _buildBannerItem(banner.bannerImage ?? '', responsive);
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Builds individual banner item
  Widget _buildBannerItem(String imageUrl, ResponsiveHelper responsive) {
    return Container(
      width: responsive.screenWidth,
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 14)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
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
  }

  /// Builds single banner without carousel
  Widget _buildSingleBanner(String imageUrl, ResponsiveHelper responsive) {
    return Container(
      width: responsive.screenWidth,
      height: responsive.bannerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 14)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
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
  }

  /// Builds skeleton loading state
  Widget _buildCarouselSkeleton(ResponsiveHelper responsive) {
    return Container(
      width: responsive.screenWidth,
      height: responsive.bannerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        color: Colors.grey[300],
      ),
      child: Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          duration: const Duration(milliseconds: 1500),
        ),
        child: Skeleton.leaf(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
              color: Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }
}
