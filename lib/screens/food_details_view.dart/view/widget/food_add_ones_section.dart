import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../restaurant_detail_view/controller/restaurant_detail_view_controller.dart';
import '../../../restaurant_detail_view/model/restaurent_details_model.dart';

class FoodAddOnsSection extends StatelessWidget {
  final List<AddOn>? addOns;
  final String foodId;

  const FoodAddOnsSection({super.key, required this.addOns, required this.foodId});

  @override
  Widget build(BuildContext context) {
    if (addOns == null || addOns!.isEmpty) {
      return SizedBox();
    }

    return GetBuilder<RestaurantDetailViewController>(
      id: 'addons_list',
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text(text: 'Add Ons', size: 16, fontWeight: FontWeight.w600),
            10.h,
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final addOn = addOns![index];
                return _buildAddOnTile(controller, addOn);
              },
              separatorBuilder: (context, index) => 16.h,
              itemCount: addOns!.length,
            ),
            SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _buildAddOnTile(RestaurantDetailViewController controller, AddOn addOn) {
    return GestureDetector(
      onTap: () => controller.toggleAddOn(addOn.addOnId ?? ''),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.white,
          boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            image(url: addOn.image ?? '', height: 40, width: 40, borderRadius: BorderRadius.circular(4)),
            16.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(
                    text: addOn.name ?? '',
                    size: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
                  4.h,
                  text(
                    text: '₹ ${addOn.price?.toInt() ?? 0}',
                    size: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColor.black.withOpacity(0.6),
                  ),
                ],
              ),
            ),
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: controller.isAddOnSelected(addOn.addOnId ?? '') ? AppColor.appPrimary : AppColor.white,
                border: Border.all(
                  color:
                      controller.isAddOnSelected(addOn.addOnId ?? '')
                          ? AppColor.appPrimary
                          : AppColor.appPrimary.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  controller.isAddOnSelected(addOn.addOnId ?? '')
                      ? Icon(Icons.done, color: AppColor.white, size: 13)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
