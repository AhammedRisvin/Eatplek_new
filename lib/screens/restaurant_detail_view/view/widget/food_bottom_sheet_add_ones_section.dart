import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/util/app_color.dart';
import '../../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import '../../model/restaurent_details_model.dart';

class FoodBottomSheetAddOnsSection extends StatelessWidget {
  final Food foodItem;

  const FoodBottomSheetAddOnsSection({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    if (foodItem.addOns == null || foodItem.addOns!.isEmpty) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildAddOnsHeader(), 20.h, _buildAddOnsList()],
    );
  }

  Widget _buildAddOnsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(text: 'Add Ons', size: 18, fontWeight: FontWeight.w600),
          3.h,
          text(
            text: 'Make your meal better with these add-ons.',
            size: 12,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnsList() {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'addons_list',
      builder: (controller) {
        return ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final addOn = foodItem.addOns![index];
            return _buildAddOnTile(controller, addOn, foodItem.foodId!);
          },
          separatorBuilder: (context, index) => 16.h,
          itemCount: foodItem.addOns!.length,
        );
      },
    );
  }

  Widget _buildAddOnTile(RestaurantDetailViewController controller, AddOn addOn, String foodId) {
    return GestureDetector(
      onTap: () => controller.toggleAddOn(addOn.addOnId ?? ''),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.white,
          boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
        ),
        margin: EdgeInsets.symmetric(horizontal: 16),
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
                  width: controller.isAddOnSelected(addOn.addOnId ?? '') ? 2 : 1.5,
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
