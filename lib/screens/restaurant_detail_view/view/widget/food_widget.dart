import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import '../../model/restaurent_details_model.dart';
import 'quantity_control_widget.dart';

class FoodWidget extends StatelessWidget {
  final Food foodItem;

  const FoodWidget({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<RestaurantDetailViewController>().navigateToFoodDetail(foodItem);
      },
      child: Container(
        width: context.wp(100),
        height: 200,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColor.white,
          boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: image(
                url: foodItem.foodImage ?? '',
                height: 120,
                width: context.wp(100),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            10.h,
            Row(
              children: [
                Expanded(
                  child: text(
                    text: foodItem.foodName ?? '',
                    size: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColor.black,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            8.h,
            Row(
              children: [
                text(
                  text: '₹ ${(foodItem.discountPrice ?? foodItem.foodPrice ?? 0).toInt()}',
                  size: 16,
                  fontWeight: FontWeight.w600,
                ),
                if (foodItem.discountPrice != null &&
                    foodItem.discountPrice != foodItem.actualPrice &&
                    foodItem.actualPrice != null) ...[
                  8.w,
                  text(
                    text: '₹ ${foodItem.actualPrice?.toInt()}',
                    size: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.2),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColor.black.withOpacity(0.2),
                  ),
                ],
                Spacer(),
                QuantityControlWidget(
                  quantity: 0,
                  onIncrease: () => _showFoodBottomSheet(context, foodItem),
                  onDecrease: () {},
                  showRemoveButton: false,
                  buttonSize: 28,
                  iconSize: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFoodBottomSheet(BuildContext context, Food foodItem) {
    final controller = Get.find<RestaurantDetailViewController>();
    controller.selectFoodItem(foodItem);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.scaffoldColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (context) => FoodDetailsBottomSheet(),
    );
  }
}

class FoodDetailsBottomSheet extends StatelessWidget {
  const FoodDetailsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'bottom_sheet_content',
      builder: (controller) {
        final foodItem = controller.selectedFoodItem;
        if (foodItem == null) return SizedBox();

        final hasCustomizations = controller.hasCustomizations;
        final hasAddOns = controller.hasAddOns;

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
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
                  _buildHandleBar(),
                  _buildHeader(foodItem),
                  Divider(color: AppColor.black.withOpacity(0.1), thickness: 1.5),
                  if (!hasCustomizations && !hasAddOns) ...[
                    _buildSelectedFoodItemWithQuantity(controller, foodItem),
                    Expanded(
                      child: Center(
                        child: text(
                          text: 'No customizations or add-ons available',
                          size: 16,
                          color: AppColor.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ] else if (!hasCustomizations && hasAddOns) ...[
                    _buildSelectedFoodItemWithQuantity(controller, foodItem),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_buildAddOnsHeader(), 20.h, _buildAddOnsList(controller, foodItem), 100.h],
                        ),
                      ),
                    ),
                  ] else if (hasCustomizations) ...[
                    _buildSelectedFoodItem(controller, foodItem),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCustomizationSection(controller, foodItem),
                            20.h,
                            if (hasAddOns) ...[_buildAddOnsHeader(), 20.h, _buildAddOnsList(controller, foodItem)],
                            100.h,
                          ],
                        ),
                      ),
                    ),
                  ],

                  _buildCheckoutSection(controller),
                ],
              ),
            );
          },
        );
      },
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

  Widget _buildHeader(Food foodItem) {
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

  // Scenario 1 & 2: Food item with quantity control
  Widget _buildSelectedFoodItemWithQuantity(RestaurantDetailViewController controller, Food foodItem) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColor.white),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 17),
      child: Row(
        children: [
          image(url: foodItem.foodImage ?? '', height: 40, width: 40, borderRadius: BorderRadius.circular(4)),
          20.w,
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
                text(
                  text: '₹ ${(foodItem.discountPrice ?? foodItem.foodPrice ?? 0).toInt()}',
                  size: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          GetBuilder<RestaurantDetailViewController>(
            id: 'food_quantity_widget',
            builder: (controller) {
              return QuantityControlWidget(
                quantity: controller.getCustomizationCount(foodItem.foodId ?? ''),
                onIncrease: () => controller.toggleCustomization(''),
                onDecrease: controller.decreaseCustomization,
                showRemoveButton: true,
                buttonSize: 32,
                iconSize: 14,
              );
            },
          ),
        ],
      ),
    );
  }

  // Scenario 3: Food item without quantity control (moved to customization tiles)
  Widget _buildSelectedFoodItem(RestaurantDetailViewController controller, Food foodItem) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 17),
      child: Row(
        children: [
          image(url: foodItem.foodImage ?? '', height: 40, width: 40, borderRadius: BorderRadius.circular(4)),
          20.w,
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
                text(
                  text: '₹ ${(foodItem.discountPrice ?? foodItem.foodPrice ?? 0).toInt()}',
                  size: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSection(RestaurantDetailViewController controller, Food foodItem) {
    if (!controller.hasCustomizations || foodItem.customizations == null) {
      return SizedBox();
    }

    return GetBuilder<RestaurantDetailViewController>(
      id: 'customization_widget',
      builder: (controller) {
        final customizations = foodItem.customizations!;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(text: 'Customize Your Food', size: 18, fontWeight: FontWeight.w600),
              3.h,
              text(
                text: 'Choose your preferred size or variant.',
                size: 12,
                fontWeight: FontWeight.w400,
                color: AppColor.black.withOpacity(0.6),
              ),
              20.h,
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final customization = customizations[index];
                  return _buildCustomizationTile(controller, customization, foodItem.foodId!);
                },
                separatorBuilder: (context, index) => 16.h,
                itemCount: customizations.length,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomizationTile(
    RestaurantDetailViewController controller,
    Customization customization,
    String foodId,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.white,
        boxShadow: [BoxShadow(color: Color(0xff000000).withOpacity(0.04), blurRadius: 14, offset: Offset(0, 0))],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(text: customization.name ?? '', size: 14, fontWeight: FontWeight.w600, color: AppColor.black),
                4.h,
                text(
                  text: '₹ ${customization.price?.toInt() ?? 0}',
                  size: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          GetBuilder<RestaurantDetailViewController>(
            id: 'customization_widget',
            builder: (controller) {
              final quantity = controller.getCustomizationCount(foodId);
              return QuantityControlWidget(
                quantity: quantity,
                onIncrease: () => controller.toggleCustomization(customization.customizationId ?? ''),
                onDecrease: controller.decreaseCustomization,
                showRemoveButton: quantity > 0,
                buttonSize: 32,
                iconSize: 14,
              );
            },
          ),
        ],
      ),
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

  Widget _buildAddOnsList(RestaurantDetailViewController controller, Food foodItem) {
    if (!controller.hasAddOns || foodItem.addOns == null) {
      return SizedBox();
    }

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

  Widget _buildCheckoutSection(RestaurantDetailViewController controller) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'total_price',
      builder: (controller) {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: AppColor.white,
            border: BorderDirectional(top: BorderSide(color: AppColor.black.withOpacity(0.1), width: 1)),
            boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.08), blurRadius: 14, offset: Offset(0, -2))],
          ),
          padding: EdgeInsets.only(top: 11, left: 16, right: 16, bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      text: 'Total Amount',
                      size: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.black.withOpacity(0.6),
                    ),
                    text(
                      text: '₹${controller.getTotalPrice().toStringAsFixed(0)}',
                      size: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                  ],
                ),
              ),
              button(
                name: 'Add to Cart',
                onTap: () {
                  controller.logAndAddToCartFromBottomSheet();
                  Get.back();
                },
                width: 125,
                height: 50,
                color: AppColor.appPrimary,
                textColor: AppColor.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                borderRadius: BorderRadius.circular(100),
              ),
            ],
          ),
        );
      },
    );
  }
}
