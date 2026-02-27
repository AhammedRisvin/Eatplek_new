import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../model/new_home_model.dart';

class VendorCardWidget extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback? onTap;
  final double? cardHeight;
  final bool showFullOverlay;

  const VendorCardWidget({
    super.key,
    required this.vendor,
    this.onTap,
    this.cardHeight,
    this.showFullOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
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
              children: [
                _buildVendorImage(responsive),
                SizedBox(height: responsive.spacing10),
                _buildVendorInfo(responsive),
                SizedBox(height: responsive.spacing10),
                _buildVendorLocation(responsive),
                SizedBox(height: responsive.spacing10),
              ],
            ),
            if ((vendor.schedule?.isClosed ?? true) && showFullOverlay)
              _buildClosedOverlay(responsive),
            if (vendor.schedule?.isClosed == false) _buildOpenBadge(responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorImage(ResponsiveHelper responsive) {
    return Expanded(
      flex: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(responsive.cardBorderRadius),
          topRight: Radius.circular(responsive.cardBorderRadius),
        ),
        child: Image.network(
          vendor.coverImage ?? '',
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: SizedBox(
                  width: responsive.spacing30,
                  height: responsive.spacing30,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVendorInfo(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing12),
      child: Row(
        children: [
          Expanded(
            child: text(
              text: vendor.hotelName ?? 'Unknown Vendor',
              size: responsive.fontSize14,
              fontWeight: FontWeight.w500,
              color: AppColor.black,
              maxLines: 2,
              overFlow: TextOverflow.ellipsis,
            ),
          ),
          SvgPicture.string(starSvg),
          SizedBox(width: responsive.spacing3),
          text(
            text: (vendor.averageRating ?? 0).toString(),
            size: responsive.fontSize12,
            fontWeight: FontWeight.w600,
            color: AppColor.black,
          ),
        ],
      ),
    );
  }

  Widget _buildVendorLocation(ResponsiveHelper responsive) {
    String location = vendor.place ?? 'Unknown Location';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing12),
      child: Row(
        children: [
          SvgPicture.string(locationSvg),
          SizedBox(width: responsive.spacing5),
          Expanded(
            child: text(
              text: location,
              size: responsive.fontSize12,
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

  Widget _buildOpenBadge(ResponsiveHelper responsive) {
    return Positioned(
      top: responsive.spacing10,
      left: responsive.spacing10,
      child: button(
        name: 'Open',
        width: responsive.spacing55,
        height: responsive.spacing28,
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        fontSize: responsive.fontSize12,
        fontWeight: FontWeight.w500,
        onTap: () {},
        color: const Color(0xFF27ae60),
        borderColor: const Color(0xFF27ae60),
        textColor: AppColor.white,
      ),
    );
  }

  Widget _buildClosedOverlay(ResponsiveHelper responsive) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              text(
                text: 'Closed',
                size: responsive.fontSize16,
                fontWeight: FontWeight.w600,
                color: AppColor.redColor,
              ),
              SizedBox(height: responsive.spacing4),
              text(
                text: 'Check opening hours',
                size: responsive.fontSize12,
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
