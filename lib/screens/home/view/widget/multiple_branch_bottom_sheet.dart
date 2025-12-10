import 'package:flutter/material.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../model/new_home_model.dart';
import 'restaurant_card_widget.dart';

class MultipleBranchBottomSheet extends StatelessWidget {
  final String vendorName;
  final List<Vendor> branches;
  final Function(Vendor) onBranchSelected;

  const MultipleBranchBottomSheet({
    super.key,
    required this.vendorName,
    required this.branches,
    required this.onBranchSelected,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return Container(
      width: responsive.screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(responsive.largeBorderRadius),
          topRight: Radius.circular(responsive.largeBorderRadius),
        ),
        color: AppColor.scaffoldColor,
      ),
      constraints: BoxConstraints(maxHeight: responsive.screenHeight * 0.8),
      padding: EdgeInsets.only(
        left: responsive.spacing16,
        right: responsive.spacing16,
        top: responsive.spacing10,
        bottom: responsive.spacing20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator
            Align(
              alignment: Alignment.center,
              child: Container(
                width: responsive.spacing120,
                height: responsive.spacing4,
                margin: EdgeInsets.only(bottom: responsive.spacing10),
                decoration: BoxDecoration(
                  color: const Color(0XFFD9D9D9),
                  borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing6),
            // Title
            text(
              text: 'Select a Branch',
              size: responsive.fontSize18,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
            ),
            SizedBox(height: responsive.spacing6),
            text(
              text: '$vendorName has multiple branches within your selected location radius.',
              size: responsive.fontSize12,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
            ),
            SizedBox(height: responsive.spacing8),
            Divider(color: AppColor.black.withOpacity(0.1), thickness: 1),
            SizedBox(height: responsive.spacing8),
            text(
              text: 'Please choose your preferred branch to continue your order.',
              size: responsive.fontSize12,
              fontWeight: FontWeight.w300,
              color: AppColor.black.withOpacity(0.6),
            ),
            SizedBox(height: responsive.spacing20),
            // Branches Grid
            _buildBranchesGrid(responsive),
            SizedBox(height: responsive.spacing20),
          ],
        ),
      ),
    );
  }

  /// Build branches grid with vendor cards
  Widget _buildBranchesGrid(ResponsiveHelper responsive) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.gridCrossAxisCount,
        mainAxisSpacing: responsive.gridMainAxisSpacing,
        crossAxisSpacing: responsive.gridCrossAxisSpacing,
        childAspectRatio: responsive.gridChildAspectRatio,
      ),
      itemCount: branches.length,
      itemBuilder: (context, index) {
        final branch = branches[index];
        return GestureDetector(
          onTap: () => onBranchSelected(branch),
          child: VendorCardWidget(vendor: branch, onTap: () => onBranchSelected(branch), showFullOverlay: true),
        );
      },
    );
  }
}
