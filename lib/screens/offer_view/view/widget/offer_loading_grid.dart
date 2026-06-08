import 'package:flutter/material.dart';

import '../../../../core/util/responsive_helper.dart';

class OfferLoadingGrid extends StatelessWidget {
  const OfferLoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.gridCrossAxisCount,
          mainAxisSpacing: responsive.gridMainAxisSpacing,
          crossAxisSpacing: responsive.gridCrossAxisSpacing,
          childAspectRatio: responsive.gridChildAspectRatioForFood,
        ),
        itemCount: 6,
        itemBuilder:
            (_, __) => Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(
                  responsive.cardBorderRadius,
                ),
              ),
            ),
      ),
    );
  }
}
