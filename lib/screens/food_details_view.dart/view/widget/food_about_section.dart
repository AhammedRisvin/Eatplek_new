import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import 'dotted_line_painter.dart';

class FoodAboutSection extends StatelessWidget {
  const FoodAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        3.h,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [text(text: 'Non - veg', size: 14, fontWeight: FontWeight.w500, color: Color(0XFFFF6E00))],
        ),
        20.h,
        Row(
          children: [
            Container(
              height: 16,
              width: 4,
              decoration: BoxDecoration(color: AppColor.appPrimary, borderRadius: BorderRadius.circular(100)),
              margin: EdgeInsets.only(right: 6),
            ),
            text(text: 'About The Food', size: 16, fontWeight: FontWeight.w600, color: AppColor.black),
          ],
        ),
        10.h,
        text(
          text:
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
      ],
    );
  }
}
