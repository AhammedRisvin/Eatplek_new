import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../../../../core/util/app_color.dart';
import '../../../../../core/util/common_widgets.dart';
import '../../model/restaurent_details_model.dart';

class FoodBottomSheetHeader extends StatelessWidget {
  final Food foodItem;

  const FoodBottomSheetHeader({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandleBar(),
        _buildHeaderContent(),
        Divider(color: AppColor.black.withOpacity(0.1), thickness: 1.5),
      ],
    );
  }

  Widget _buildHandleBar() {
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 120,
          height: 4,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: Color(0XFFD9D9D9)),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(text: 'Your Cart Summary', size: 18, fontWeight: FontWeight.w600),
          6.h,
          text(
            text: 'Your selected items and add-ons at a glance.',
            size: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
