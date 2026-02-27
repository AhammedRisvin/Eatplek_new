import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/responsive_helper.dart';

class ResponsiveSpecialInstructionsWidget extends StatelessWidget {
  final String instructions;

  const ResponsiveSpecialInstructionsWidget({super.key, required this.instructions});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.widthPercent(100),
      padding: responsive.containerPadding,
      decoration: responsive.responsiveContainer(borderColor: AppColor.appPrimary.withOpacity(0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            text: 'Special Instructions',
            size: responsive.fontSize14,
            fontWeight: FontWeight.w600,
            color: AppColor.appPrimary,
          ),
          SizedBox(height: responsive.spacing8),
          text(
            text: instructions,
            size: responsive.fontSize13,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}
