import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../controller/restaurant_detail_view_controller.dart';
import '../../model/food_add_on_model.dart';
import 'quantity_control_widget.dart'; // Import the reusable widget

class FoodWidget extends StatelessWidget {
  final FoodItem foodItem;

  const FoodWidget({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to food detail page
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
                url: foodItem.imageUrl,
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
                    text: foodItem.name,
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
                text(text: '₹ ${foodItem.price.toInt()}', size: 16, fontWeight: FontWeight.w600),
                if (foodItem.hasDiscount) ...[
                  8.w,
                  text(
                    text: '₹ ${foodItem.originalPrice.toInt()}',
                    size: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.2),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColor.black.withOpacity(0.2),
                  ),
                ],
                Spacer(),
                QuantityControlWidget(
                  quantity: 1,
                  onIncrease: () => _showFoodBottomSheet(context, foodItem),
                  onDecrease: () {}, // Not used for this case
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

  void _showFoodBottomSheet(BuildContext context, FoodItem foodItem) {
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
                  // Handle bar
                  _buildHandleBar(),

                  // Header
                  _buildHeader(foodItem),

                  // Divider
                  Divider(color: AppColor.black.withOpacity(0.06), thickness: 1),

                  // Selected item with quantity controls
                  _buildSelectedFoodItem(controller, foodItem),

                  // Add-ons section
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAddOnsHeader(),
                          20.h,
                          _buildAddOnsList(controller),
                          100.h, // Extra space for scrolling
                        ],
                      ),
                    ),
                  ),

                  // Bottom checkout section
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

  Widget _buildHeader(FoodItem foodItem) {
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

  Widget _buildSelectedFoodItem(RestaurantDetailViewController controller, FoodItem foodItem) {
    return GetBuilder<RestaurantDetailViewController>(
      id: 'quantity_controls',
      builder: (controller) {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColor.white),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 17),
          child: Row(
            children: [
              image(url: foodItem.imageUrl, height: 40, width: 40, borderRadius: BorderRadius.circular(4)),
              20.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      text: foodItem.name,
                      size: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
                    4.h,
                    text(
                      text: '₹ ${foodItem.price.toInt()}',
                      size: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColor.black.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
              QuantityControlWidget(
                quantity: controller.currentQuantity,
                onIncrease: controller.increaseQuantity,
                onDecrease: controller.decreaseQuantity,
                showRemoveButton: true,
                buttonSize: 28,
                iconSize: 14,
                margin: EdgeInsets.only(right: 7),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOnsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(text: 'Add Ons', size: 18, fontWeight: FontWeight.w600),
          6.h,
          text(
            text: 'Make your meal better with these add-ons.',
            size: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnsList(RestaurantDetailViewController controller) {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final addOn = controller.availableAddOns[index];
        return GetBuilder<RestaurantDetailViewController>(
          id: 'addon_${addOn.id}',
          builder: (controller) {
            return AddOnSelectionWidget(
              id: addOn.id,
              name: addOn.name,
              price: '₹ ${addOn.price.toInt()}',
              imageUrl: addOn.imageUrl,
              isSelected: addOn.isSelected,
              onTap: () => controller.toggleAddOn(addOn.id),
            );
          },
        );
      },
      separatorBuilder: (context, index) => 20.h,
      itemCount: controller.availableAddOns.length,
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
                      text: '₹${controller.totalPrice.toStringAsFixed(0)}',
                      size: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                  ],
                ),
              ),
              button(
                name: 'Add to Cart',
                onTap: controller.addToCart,
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
