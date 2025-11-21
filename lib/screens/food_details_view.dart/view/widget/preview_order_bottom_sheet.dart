import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/app_color.dart';
import '../../../restaurant_detail_view/model/restaurent_details_model.dart';
import 'food_preview_sheet.dart';

class PreviewOrderBottomSheet extends StatelessWidget {
  final Food foodItem;
  final String foodId;
  final List<Customization>? customizations;
  final List<AddOn> selectedAddOns;

  const PreviewOrderBottomSheet({
    super.key,
    required this.foodItem,
    required this.foodId,
    required this.customizations,
    required this.selectedAddOns,
  });

  @override
  Widget build(BuildContext context) {
    final hasCustomizations = customizations != null && customizations!.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColor.scaffoldColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PreviewSheetHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.h,
                      PreviewFoodItem(foodItem: foodItem, foodId: foodId),
                      20.h,
                      if (hasCustomizations) ...[PreviewCustomizationsSection(customizations: customizations), 20.h],
                      if (selectedAddOns.isNotEmpty) ...[PreviewAddOnsSection(selectedAddOns: selectedAddOns), 20.h],
                      PreviewPriceSummary(foodId: foodId),
                      40.h,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
