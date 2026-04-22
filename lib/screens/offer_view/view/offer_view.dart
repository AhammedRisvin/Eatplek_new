import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/util/assets.dart';
import '../controller/offer_controller.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  final OfferController _controller = Get.put(OfferController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              20.h,
              _buildSearchField(),
              10.h,
              _buildCategoryFilter(),
              17.h,
              _buildRestaurantList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return text(
      text: 'Today\'s Hot Offers',
      size: 26,
      fontWeight: FontWeight.w700,
    );
  }

  Widget _buildSearchField() {
    return buildCommonTextFormField(
      hintText: 'Search Restaurant',
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      controller: _searchController,
      context: context,
      hintTextSize: 13,
      bgColor: AppColor.white,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SvgPicture.string(searchSvg, color: const Color(0xFF474747)),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: GetBuilder<OfferController>(
        id: 'category_list',
        builder: (controller) {
          return ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: controller.offerCategories.length,
            itemBuilder: (context, index) => _buildCategoryItem(index),
            separatorBuilder: (context, index) => 10.w,
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    final isSelected = _controller.selectedCategoryIndex == index;

    return GestureDetector(
      onTap: () => _controller.updateSelectedCategory(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? AppColor.appPrimary : AppColor.white,
          border: Border.all(color: AppColor.black.withOpacity(0.06)),
        ),
        child: text(
          text: _controller.offerCategories[index],
          size: 14,
          fontWeight: FontWeight.w400,
          color:
              isSelected
                  ? AppColor.white
                  : const Color(0xff474747).withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildRestaurantList() {
    return GetBuilder<OfferController>(
      id: 'restaurant_list',
      builder: (controller) {
        final restaurants = controller.filteredRestaurants;

        if (restaurants.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: restaurants.length,
          itemBuilder:
              (context, index) => _buildRestaurantCard(restaurants[index]),
          separatorBuilder: (context, index) => 15.h,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: AppColor.black.withOpacity(0.3),
          ),
          10.h,
          text(
            text: 'No offers available for this category',
            size: 16,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(RestaurantOffer restaurant) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.restaurantDetail);
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              _buildBackgroundImage(restaurant.imageUrl),
              _buildGradientOverlay(),
              _buildCardContent(restaurant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(String imageUrl) {
    return Positioned.fill(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColor.black.withOpacity(0.1),
            child: const Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColor.black.withOpacity(0.3),
              AppColor.black.withOpacity(0.7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(RestaurantOffer restaurant) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(restaurant),
            const Spacer(),
            _buildRestaurantName(restaurant.name),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(RestaurantOffer restaurant) {
    return Row(
      children: [
        _buildRatingBadge(restaurant.rating),
        const Spacer(),
        _buildLocationInfo(restaurant.location),
      ],
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFffc107).withOpacity(0.9),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Color(0XFFFF6E00), size: 16),
          5.w,
          text(
            text: rating.toString(),
            size: 12,
            fontWeight: FontWeight.w600,
            color: AppColor.white,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String location) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: text(
            text: location,
            size: 13,
            fontWeight: FontWeight.w500,
            color: AppColor.white,
          ),
        ),
        8.w,
        SvgPicture.string(
          locationSvg,
          color: AppColor.white,
          height: 16,
          width: 16,
        ),
      ],
    );
  }

  Widget _buildRestaurantName(String name) {
    return text(
      text: name,
      size: 18,
      fontWeight: FontWeight.w600,
      color: AppColor.white,
    );
  }
}
