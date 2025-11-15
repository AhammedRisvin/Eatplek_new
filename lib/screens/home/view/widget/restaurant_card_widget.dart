import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../model/home_model.dart';

class RestaurantCardWidget extends StatelessWidget {
  final Vendor restaurant;
  final VoidCallback? onTap;
  final double? cardHeight;
  final bool showFullOverlay;

  const RestaurantCardWidget({
    super.key,
    required this.restaurant,
    this.onTap,
    this.cardHeight,
    this.showFullOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColor.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 34.35,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildRestaurantImage(), 10.h, _buildRestaurantInfo(), 10.h, _buildRestaurantLocation(), 10.h],
            ),
            if (!(restaurant.isOpen ?? true) && showFullOverlay) _buildClosedOverlay(),
            if (restaurant.isOpen ?? true) _buildOpenBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantImage() {
    return Expanded(
      flex: 3,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: Image.network(
          restaurant.restaurantImage ?? '',
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: text(
              text: restaurant.restaurantName ?? 'Unknown Restaurant',
              size: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.black,
              maxLines: 2,
              overFlow: TextOverflow.ellipsis,
            ),
          ),
          SvgPicture.string(starSvg),
          3.w,
          text(
            text: (restaurant.averageRating ?? 0).toString(),
            size: 12,
            fontWeight: FontWeight.w600,
            color: AppColor.black,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantLocation() {
    String location = restaurant.address?.city ?? 'Unknown Location';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SvgPicture.string(locationSvg),
          5.w,
          Expanded(
            child: text(
              text: location,
              size: 12,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
              maxLines: 2,
              overFlow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenBadge() {
    return Positioned(
      top: 10,
      left: 10,
      child: button(
        name: 'Open',
        width: 55,
        height: 28,
        borderRadius: BorderRadius.circular(40),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        onTap: () {},
        color: const Color(0xFF27ae60),
        borderColor: const Color(0xFF27ae60),
        textColor: AppColor.white,
      ),
    );
  }

  Widget _buildClosedOverlay() {
    String openingTime = restaurant.operatingHours?.openTime ?? '10:00 AM';

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(color: AppColor.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              text(text: 'Closed', size: 16, fontWeight: FontWeight.w600, color: AppColor.redColor),
              4.h,
              text(
                text: 'Opens tomorrow at $openingTime',
                size: 12,
                fontWeight: FontWeight.w400,
                color: AppColor.white,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
