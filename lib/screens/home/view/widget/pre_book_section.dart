import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../model/new_home_model.dart';

class PrebookListSection extends StatelessWidget {
  final List<PrebookList> prebookList;

  const PrebookListSection({super.key, required this.prebookList});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    if (prebookList.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final validPrebooks =
        prebookList.where((prebook) {
          final startDate = prebook.prebookStartDate;
          final endDate = prebook.prebookEndDate;

          if (startDate == null || endDate == null) return false;

          return now.isAfter(startDate) && now.isBefore(endDate);
        }).toList();

    if (validPrebooks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: responsive.spacing30),
        Padding(
          padding: responsive.horizontalPadding20,
          child: Row(
            children: [
              Container(
                height: responsive.spacing16,
                width: responsive.spacing4,
                decoration: BoxDecoration(
                  color: AppColor.appPrimary,
                  borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                ),
                margin: EdgeInsets.only(right: responsive.spacing8),
              ),
              text(
                text: 'Pre-Book Offers',
                size: responsive.fontSize16,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
              SizedBox(width: responsive.spacing8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing8, vertical: responsive.spacing3),
                decoration: BoxDecoration(
                  color: AppColor.appPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
                ),
                child: text(
                  text: 'Limited Time',
                  size: responsive.fontSize10,
                  fontWeight: FontWeight.w500,
                  color: AppColor.appPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.spacing16),
        SizedBox(
          height: responsive.spacing280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: validPrebooks.length,
            padding: responsive.horizontalPadding20,
            itemBuilder: (context, index) {
              final prebook = validPrebooks[index];
              return _PrebookCard(prebook: prebook);
            },
          ),
        ),
      ],
    );
  }
}

class _PrebookCard extends StatelessWidget {
  final PrebookList prebook;

  const _PrebookCard({required this.prebook});

  String _getRemainingTimeText(DateTime? endDate) {
    if (endDate == null) return 'Offer ends soon';
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    if (difference <= 0) {
      return 'Ends today';
    } else if (difference < 7) {
      return 'Ends in $difference day${difference > 1 ? 's' : ''}';
    } else {
      return 'Ends ${endDate.day} ${_getMonthName(endDate.month)}';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final basePrice = prebook.basePrice ?? 0.0;
    final effectivePrice = prebook.effectivePrice ?? 0.0;
    final cardWidth = responsive.screenWidth * 0.4; // 40% of screen width

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.preBookDetailView, arguments: prebook);
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(right: responsive.spacing12),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
          boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
          border: Border.all(color: AppColor.black.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(responsive.largeBorderRadius),
                    topRight: Radius.circular(responsive.largeBorderRadius),
                  ),
                  child: Image.network(
                    prebook.foodImage ?? '',
                    width: cardWidth,
                    height: responsive.cardImageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: cardWidth,
                        height: responsive.cardImageHeight,
                        color: AppColor.black.withOpacity(0.1),
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColor.black.withOpacity(0.3),
                          size: responsive.iconSizeLarge,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: responsive.spacing8,
                  right: responsive.spacing8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing8, vertical: responsive.spacing4),
                    decoration: BoxDecoration(
                      color: AppColor.appPrimary,
                      borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
                      boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.1), blurRadius: 4)],
                    ),
                    child: text(
                      text: _getRemainingTimeText(prebook.prebookEndDate),
                      size: responsive.fontSize9,
                      fontWeight: FontWeight.w600,
                      color: AppColor.white,
                    ),
                  ),
                ),
                Positioned(
                  top: responsive.spacing8,
                  left: responsive.spacing8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing6, vertical: responsive.spacing3),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
                      boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.1), blurRadius: 4)],
                    ),
                    child: text(
                      text: 'PRE-BOOK',
                      size: responsive.fontSize8,
                      fontWeight: FontWeight.w700,
                      color: AppColor.appPrimary,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(responsive.spacing10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      text: prebook.foodName ?? '',
                      size: responsive.fontSize13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                      maxLines: 3,
                      overFlow: TextOverflow.ellipsis,
                    ),
                    text(
                      text: prebook.vendor?.hotelName ?? 'Restaurant',
                      size: responsive.fontSize11,
                      fontWeight: FontWeight.w400,
                      color: AppColor.black.withOpacity(0.6),
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
                    _buildPriceSection(basePrice, effectivePrice, responsive),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(double basePrice, double effectivePrice, ResponsiveHelper responsive) {
    final showStrikethrough = basePrice != effectivePrice && basePrice > 0;

    return Row(
      children: [
        text(
          text: '₹${effectivePrice.toStringAsFixed(0)}',
          size: responsive.fontSize13,
          fontWeight: FontWeight.w600,
          color: AppColor.appPrimary,
        ),
        SizedBox(width: responsive.spacing7),
        if (showStrikethrough) ...[
          text(
            text: '₹${basePrice.toStringAsFixed(0)}',
            size: responsive.fontSize11,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.5),
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColor.black,
          ),
        ],
      ],
    );
  }
}
