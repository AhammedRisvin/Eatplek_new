import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../../../../core/util/app_color.dart';
import '../../../../../core/util/common_widgets.dart';
import '../../../cart/view/widget/dotted_line_painter.dart';
import '../../../home/model/new_home_model.dart';

class PrebookAboutSection extends StatelessWidget {
  final PrebookList? prebookData;

  const PrebookAboutSection({super.key, this.prebookData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        20.h,
        Row(
          children: [
            Container(
              height: 16,
              width: 4,
              decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
              margin: EdgeInsets.only(right: 6),
            ),
            text(text: 'About The Pre-Book', size: 16, fontWeight: FontWeight.w600, color: AppColor.black),
          ],
        ),
        10.h,
        text(
          text:
              prebookData?.description ??
              '''Juicy grilled chicken patty layered with fresh lettuce, creamy mayo, and melted cheese, all tucked inside a soft sesame bun. A timeless favorite made to satisfy every craving.''',
          size: 14,
          fontWeight: FontWeight.w400,
          color: AppColor.black.withOpacity(0.6),
          textAlign: TextAlign.justify,
        ),
        10.h,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            height: 1,
            width: double.infinity,
            child: CustomPaint(painter: DottedLinePainter(color: AppColor.black.withOpacity(0.1))),
          ),
        ),
        20.h,
        // Pre-booking details section
        Row(
          children: [
            Container(
              height: 16,
              width: 4,
              decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
              margin: EdgeInsets.only(right: 6),
            ),
            text(text: 'Pre-Booking Period', size: 16, fontWeight: FontWeight.w600, color: AppColor.black),
          ],
        ),
        10.h,
        _buildPreBookingDetails(),
        20.h,
      ],
    );
  }

  Widget _buildPreBookingDetails() {
    final startDate = prebookData?.prebookStartDate;
    final endDate = prebookData?.prebookEndDate;

    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.appPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.appPrimary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.appPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today, size: 16, color: AppColor.appPrimary),
              ),
              12.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      text: 'Start Date',
                      size: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColor.black.withOpacity(0.6),
                    ),
                    4.h,
                    text(text: formatDate(startDate), size: 14, fontWeight: FontWeight.w600, color: AppColor.black),
                  ],
                ),
              ),
            ],
          ),
          12.h,
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.appPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.event_available, size: 16, color: AppColor.appPrimary),
              ),
              12.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      text: 'End Date',
                      size: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColor.black.withOpacity(0.6),
                    ),
                    4.h,
                    text(text: formatDate(endDate), size: 14, fontWeight: FontWeight.w600, color: AppColor.black),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
