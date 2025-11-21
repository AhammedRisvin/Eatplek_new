import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../restaurant_detail_view/controller/restaurant_detail_view_controller.dart';
import '../../../restaurant_detail_view/model/restaurent_details_model.dart';

class PreviewSheetHeader extends StatelessWidget {
  const PreviewSheetHeader({super.key});

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
          text(text: 'Order Summary', size: 18, fontWeight: FontWeight.w600),
          6.h,
          text(
            text: 'Review your selected items.',
            size: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}

class PreviewFoodItem extends StatelessWidget {
  final Food foodItem;
  final String foodId;

  const PreviewFoodItem({super.key, required this.foodItem, required this.foodId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          image(url: foodItem.foodImage ?? '', height: 50, width: 50, borderRadius: BorderRadius.circular(4)),
          16.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: foodItem.foodName ?? '',
                  size: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black,
                  maxLines: 1,
                  overFlow: TextOverflow.ellipsis,
                ),
                4.h,
                Row(
                  children: [
                    text(
                      text: '₹${(foodItem.discountPrice ?? foodItem.foodPrice ?? 0).toInt()}',
                      size: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                    8.w,
                    GetBuilder<RestaurantDetailViewController>(
                      id: 'food_quantity_widget',
                      builder: (controller) {
                        final qty = controller.getCustomizationCount(foodId);
                        return text(
                          text: '× $qty',
                          size: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black.withOpacity(0.6),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          GetBuilder<RestaurantDetailViewController>(
            id: 'total_price',
            builder: (controller) {
              final qty = controller.getCustomizationCount(foodId);
              final price = (foodItem.discountPrice ?? foodItem.foodPrice ?? 0) * qty;
              return text(text: '₹$price', size: 14, fontWeight: FontWeight.w600, color: AppColor.appPrimary);
            },
          ),
        ],
      ),
    );
  }
}

class PreviewCustomizationsSection extends StatelessWidget {
  final List<Customization>? customizations;

  const PreviewCustomizationsSection({super.key, required this.customizations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(text: 'Customizations', size: 14, fontWeight: FontWeight.w600),
        10.h,
        Container(
          width: Get.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColor.white,
            boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
          ),
          padding: EdgeInsets.all(12),
          child: text(
            text: customizations?.map((c) => '${c.name}').join(', ') ?? 'None',
            size: 13,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class PreviewAddOnsSection extends StatelessWidget {
  final List<AddOn> selectedAddOns;

  const PreviewAddOnsSection({super.key, required this.selectedAddOns});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(text: 'Add-Ons', size: 14, fontWeight: FontWeight.w600),
        10.h,
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final addOn = selectedAddOns[index];
            return _buildAddOnItem(addOn);
          },
          separatorBuilder: (context, index) => 8.h,
          itemCount: selectedAddOns.length,
        ),
      ],
    );
  }

  Widget _buildAddOnItem(AddOn addOn) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          image(url: addOn.image ?? '', height: 40, width: 40, borderRadius: BorderRadius.circular(4)),
          12.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  text: addOn.name ?? '',
                  size: 12,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overFlow: TextOverflow.ellipsis,
                ),
                2.h,
                text(
                  text: '₹${addOn.price?.toInt() ?? 0}',
                  size: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.appPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: text(text: '✓', size: 12, fontWeight: FontWeight.w600, color: AppColor.appPrimary),
          ),
        ],
      ),
    );
  }
}

class PreviewPriceSummary extends StatelessWidget {
  final String foodId;

  const PreviewPriceSummary({super.key, required this.foodId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(text: 'Price Breakdown', size: 14, fontWeight: FontWeight.w600),
        12.h,
        Container(
          width: Get.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColor.white,
            boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
          ),
          padding: EdgeInsets.all(12),
          child: GetBuilder<RestaurantDetailViewController>(
            id: 'total_price',
            builder: (controller) {
              final basePrice = controller.getBasePrice();
              final quantity = controller.getCustomizationCount(foodId);
              final foodTotal = basePrice * quantity;
              final addOnsTotal = controller.getAddOnsPrice();
              final totalPrice = controller.getTotalPrice();

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text(
                        text: 'Food × $quantity',
                        size: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColor.black.withOpacity(0.6),
                      ),
                      text(text: '₹${foodTotal.toStringAsFixed(0)}', size: 12, fontWeight: FontWeight.w600),
                    ],
                  ),
                  if (addOnsTotal > 0) ...[
                    8.h,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        text(
                          text: 'Add-Ons',
                          size: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black.withOpacity(0.6),
                        ),
                        text(text: '₹${addOnsTotal.toStringAsFixed(0)}', size: 12, fontWeight: FontWeight.w600),
                      ],
                    ),
                    8.h,
                    Divider(color: AppColor.black.withOpacity(0.1)),
                  ],
                  8.h,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text(text: 'Total', size: 13, fontWeight: FontWeight.w700),
                      text(
                        text: '₹${totalPrice.toStringAsFixed(0)}',
                        size: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColor.appPrimary,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
