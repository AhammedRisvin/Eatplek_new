import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/screens/cart/model/cart_model.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../food_details_view.dart/view/widget/dotted_line_painter.dart';
import '../../../restaurant_detail_view/view/widget/quantity_control_widget.dart';
import '../../controller/cart_controller.dart';

class CartFoodListWidget extends StatelessWidget {
  const CartFoodListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      id: 'cart_items',
      builder: (controller) {
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) => _buildCartItem(context, controller.cartItems[index]),
          separatorBuilder: (context, index) => 0.h,
          itemCount: controller.cartItems.length,
        );
      },
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem) {
    return Container(
      width: context.wp(100),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMainContent(cartItem),
          if (cartItem.selectedAddOns.isNotEmpty) ...[
            20.h,
            _buildDivider(),
            16.h,
            _buildAddOnsHeader(),
            16.h,
            _buildAddOnsList(cartItem),
          ],
        ],
      ),
    );
  }

  Widget _buildMainContent(CartItem cartItem) {
    return Row(
      children: [
        image(url: cartItem.imageUrl, width: 80, height: 80, borderRadius: BorderRadius.circular(10)),
        20.w,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemName(cartItem.name),
              _buildItemCategory(cartItem.category),
              _buildPriceAndQuantity(cartItem),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemName(String name) {
    return text(
      text: name,
      fontWeight: FontWeight.w600,
      size: 16,
      maxLines: 2,
      textAlign: TextAlign.start,
      overFlow: TextOverflow.ellipsis,
    );
  }

  Widget _buildItemCategory(String category) {
    return text(
      text: category,
      fontWeight: FontWeight.w400,
      size: 14,
      maxLines: 2,
      color: AppColor.black.withOpacity(0.6),
      textAlign: TextAlign.start,
      overFlow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceAndQuantity(CartItem cartItem) {
    return Row(
      children: [
        Expanded(
          child: text(
            text: 'Rs.${cartItem.totalItemPrice.toInt()}',
            fontWeight: FontWeight.w500,
            size: 18,
            maxLines: 2,
            textAlign: TextAlign.start,
            overFlow: TextOverflow.ellipsis,
          ),
        ),
        GetBuilder<CartController>(
          id: 'cart_items',
          builder: (controller) {
            return QuantityControlWidget(
              quantity: cartItem.quantity,
              onIncrease: () => controller.incrementQuantity(cartItem.id),
              onDecrease: () => controller.decrementQuantity(cartItem.id),
              showRemoveButton: true,
              buttonSize: 28,
              iconSize: 14,
              margin: const EdgeInsets.only(right: 0),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: DottedLinePainter(color: AppColor.black.withOpacity(0.1))),
    );
  }

  Widget _buildAddOnsHeader() {
    return Row(
      children: [
        text(text: 'Add Ons', fontWeight: FontWeight.w600, size: 16),
        const Spacer(),
        text(text: 'Add more', fontWeight: FontWeight.w400, size: 14, color: AppColor.black.withOpacity(0.6)),
      ],
    );
  }

  Widget _buildAddOnsList(CartItem cartItem) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => _buildAddOnItem(cartItem, index),
      separatorBuilder: (context, index) => 10.h,
      itemCount: cartItem.selectedAddOns.length,
    );
  }

  Widget _buildAddOnItem(CartItem cartItem, int index) {
    final addOn = cartItem.selectedAddOns[index];
    return GetBuilder<CartController>(
      id: 'cart_items',
      builder: (controller) {
        return AddOnSelectionWidget(
          id: addOn.id,
          name: addOn.name,
          price: '₹${addOn.price.toInt()}',
          imageUrl: addOn.imageUrl,
          isSelected: addOn.isSelected,
          onTap: () => controller.toggleAddOn(cartItem.id, addOn.id),
          margin: 0,
        );
      },
    );
  }
}
