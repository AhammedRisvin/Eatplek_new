import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/assets.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/util/responsive_helper.dart';
import '../../model/new_home_model.dart';

class VendorCardWidget extends StatefulWidget {
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
  State<VendorCardWidget> createState() => _VendorCardWidgetState();
}

class _VendorCardWidgetState extends State<VendorCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final isClosed = widget.vendor.schedule?.isClosed ?? true;

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder:
            (context, child) =>
                Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          height: widget.cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            color: AppColor.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVendorImage(responsive),
                  SizedBox(height: responsive.spacing8),
                  _buildVendorName(responsive),
                  SizedBox(height: responsive.spacing5),
                  _buildVendorMeta(responsive),
                  SizedBox(height: responsive.spacing10),
                ],
              ),
              if (isClosed && widget.showFullOverlay)
                _buildClosedOverlay(responsive),
              if (!isClosed) _buildOpenBadge(responsive),
            ],
          ),
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
        child: image(
          url: widget.vendor.coverImage ?? '',
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVendorName(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing10),
      child: Row(
        children: [
          Expanded(
            child: text(
              text: widget.vendor.hotelName ?? 'Unknown Vendor',
              size: responsive.fontSize13,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
              maxLines: 1,
              overFlow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: responsive.spacing4),
          // Rating pill — green tint
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing6,
              vertical: responsive.spacing3,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF27ae60).withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.string(
                  starSvg,
                  width: responsive.fontSize10,
                  height: responsive.fontSize10,
                ),
                SizedBox(width: responsive.spacing2),
                text(
                  text: (widget.vendor.averageRating ?? 0).toStringAsFixed(1),
                  size: responsive.fontSize10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF27ae60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorMeta(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing10),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: responsive.fontSize11,
            color: AppColor.appPrimary.withOpacity(0.5),
          ),
          SizedBox(width: responsive.spacing2),
          Expanded(
            child: text(
              text: widget.vendor.place ?? 'Unknown Location',
              size: responsive.fontSize11,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.45),
              maxLines: 1,
              overFlow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenBadge(ResponsiveHelper responsive) {
    return Positioned(
      top: responsive.spacing8,
      left: responsive.spacing8,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing8,
          vertical: responsive.spacing4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF27ae60),
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF27ae60).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: text(
          text: 'Open',
          size: responsive.fontSize10,
          fontWeight: FontWeight.w600,
          color: AppColor.white,
        ),
      ),
    );
  }

  Widget _buildClosedOverlay(ResponsiveHelper responsive) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing16,
              vertical: responsive.spacing8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                text(
                  text: 'Closed',
                  size: responsive.fontSize14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.white,
                ),
                SizedBox(height: responsive.spacing2),
                text(
                  text: 'Opens later today',
                  size: responsive.fontSize10,
                  color: AppColor.white.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
