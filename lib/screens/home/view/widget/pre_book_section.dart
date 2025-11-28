import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../model/new_home_model.dart';

class PrebookListSection extends StatelessWidget {
  final List<PrebookList> prebookList;

  const PrebookListSection({super.key, required this.prebookList});

  @override
  Widget build(BuildContext context) {
    if (prebookList.isEmpty) {
      return SizedBox.shrink();
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
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        30.h,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 4,
                decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
                margin: EdgeInsets.only(right: 8),
              ),
              text(text: 'Pre-Book Offers', size: 16, fontWeight: FontWeight.w600, color: AppColor.black),
              8.w,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColor.appPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: text(text: 'Limited Time', size: 10, fontWeight: FontWeight.w500, color: AppColor.appPrimary),
              ),
            ],
          ),
        ),
        16.h,
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: validPrebooks.length,
            padding: EdgeInsets.symmetric(horizontal: 20),
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
    final basePrice = prebook.basePrice ?? 0.0;
    final effectivePrice = prebook.effectivePrice ?? 0.0;
    const cardWidth = 160.0;

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.preBookDetailView, arguments: prebook);
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4))],
          border: Border.all(color: AppColor.black.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  child: Image.network(
                    prebook.foodImage ?? '',
                    width: cardWidth,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: cardWidth,
                        height: 140,
                        color: AppColor.black.withOpacity(0.1),
                        child: Icon(Icons.image_not_supported, color: AppColor.black.withOpacity(0.3)),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColor.appPrimary,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.1), blurRadius: 4)],
                    ),
                    child: text(
                      text: _getRemainingTimeText(prebook.prebookEndDate),
                      size: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColor.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.1), blurRadius: 4)],
                    ),
                    child: text(text: 'PRE-BOOK', size: 8, fontWeight: FontWeight.w700, color: AppColor.appPrimary),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      text: prebook.foodName ?? '',
                      size: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                      maxLines: 3,
                      overFlow: TextOverflow.ellipsis,
                    ),
                    text(
                      text: prebook.vendor?.hotelName ?? 'Restaurant',
                      size: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColor.black.withOpacity(0.6),
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
                    _buildPriceSection(basePrice, effectivePrice),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(double basePrice, double effectivePrice) {
    final showStrikethrough = basePrice != effectivePrice && basePrice > 0;

    return Row(
      children: [
        text(
          text: '₹${effectivePrice.toStringAsFixed(0)}',
          size: 13,
          fontWeight: FontWeight.w600,
          color: AppColor.appPrimary,
        ),
        7.w,
        if (showStrikethrough) ...[
          text(
            text: '₹${basePrice.toStringAsFixed(0)}',
            size: 11,
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
