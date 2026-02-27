import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import '../../model/restaurent_details_model.dart';
import 'quantity_control_widget.dart';

class FoodBottomSheetAddOnsSection extends StatelessWidget {
  final Food foodItem;

  const FoodBottomSheetAddOnsSection({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    if (foodItem.addOns == null || foodItem.addOns!.isEmpty) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildAddOnsHeader(responsive), SizedBox(height: responsive.spacing20), _buildAddOnsList(responsive)],
    );
  }

  Widget _buildAddOnsHeader(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(text: 'Add Ons', size: responsive.fontSize18, fontWeight: FontWeight.w600),
          SizedBox(height: responsive.spacing3),
          text(
            text: 'Make your meal better with these add-ons.',
            size: responsive.fontSize12,
            fontWeight: FontWeight.w400,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnsList(ResponsiveHelper responsive) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'addons_list',
      builder: (controller) {
        return ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final addOn = foodItem.addOns![index];
            return _buildAddOnTile(controller, addOn, responsive);
          },
          separatorBuilder: (context, index) => SizedBox(height: responsive.spacing16),
          itemCount: foodItem.addOns!.length,
        );
      },
    );
  }

  Widget _buildAddOnTile(RestaurantDetailViewController controller, AddOn addOn, ResponsiveHelper responsive) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.spacing8),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
      ),
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing16),
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing12, vertical: responsive.spacing10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(responsive.spacing4),
            child: image(
              url: addOn.image ?? '',
              height: responsive.spacing40,
              width: responsive.spacing40,
              borderRadius: BorderRadius.circular(responsive.spacing4),
            ),
          ),
          SizedBox(width: responsive.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: addOn.name ?? '',
                  size: responsive.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black,
                  maxLines: 1,
                  overFlow: TextOverflow.ellipsis,
                ),
                SizedBox(height: responsive.spacing4),
                text(
                  text: '₹ ${addOn.price?.toInt() ?? 0}',
                  size: responsive.fontSize12,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          GetBuilder<RestaurantDetailViewController>(
            id: 'addons_list',
            builder: (controller) {
              final quantity = controller.getAddOnCount(addOn.addOnId ?? '');
              return QuantityControlWidget(
                quantity: quantity,
                onIncrease: () => controller.toggleAddOn(addOn.addOnId ?? ''),
                onDecrease: () => controller.decreaseAddOn(addOn.addOnId ?? ''),
                showRemoveButton: quantity > 0,
                buttonSize: responsive.spacing28,
                iconSize: responsive.fontSize12,
                isCompactMode: true,
              );
            },
          ),
        ],
      ),
    );
  }
}
