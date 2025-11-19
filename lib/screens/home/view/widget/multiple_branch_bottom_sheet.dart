import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
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
    return Container(
      width: context.wp(100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: AppColor.scaffoldColor,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
      ),
      padding: const EdgeInsets.only(left: 16.0, right: 16, top: 10, bottom: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 120,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: const Color(0XFFD9D9D9), borderRadius: BorderRadius.circular(100)),
              ),
            ),
            6.h,
            // Title
            text(text: 'Select a Branch', size: 18, fontWeight: FontWeight.w600, color: AppColor.black),
            6.h,
            text(
              text: '$vendorName has multiple branches within your selected location radius.',
              size: 12,
              fontWeight: FontWeight.w400,
              color: AppColor.black.withOpacity(0.6),
            ),
            8.h,
            Divider(color: AppColor.black.withOpacity(0.1), thickness: 1),
            8.h,
            text(
              text: 'Please choose your preferred branch to continue your order.',
              size: 12,
              fontWeight: FontWeight.w300,
              color: AppColor.black.withOpacity(0.6),
            ),
            20.h,
            // Branches Grid
            _buildBranchesGrid(),
            20.h,
          ],
        ),
      ),
    );
  }

  /// Build branches grid with vendor cards
  Widget _buildBranchesGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: Get.height * 0.001,
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
