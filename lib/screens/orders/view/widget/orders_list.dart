import 'package:eatplek_app/core/util/app_color.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/util/assets.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../cart/view/widget/dotted_line_painter.dart';
import '../../controller/orders_controller.dart';
import '../../model/orders_model.dart';

class OrdersList extends StatelessWidget {
  final String orderType;
  const OrdersList({super.key, required this.orderType});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrdersController>(
      id: '${orderType.toLowerCase()}_orders',
      builder: (controller) {
        final orders = controller.getOrdersByType(orderType);

        return ListView.separated(
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final order = orders[i];
            return GetBuilder<OrdersController>(
              id: 'order_card_${order.id}',
              builder: (controllerInner) {
                // Get fresh order data to ensure we have the latest status
                final freshOrders = controllerInner.getOrdersByType(orderType);
                final freshOrder = freshOrders.firstWhere((o) => o.id == order.id, orElse: () => order);
                return _buildOrderCard(freshOrder, controllerInner);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, OrdersController controller) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHotelHeader(order.hotelName),
          16.h,
          _buildOrderContent(order, controller),
          20.h,
          _buildDottedDivider(),
          16.h,
          _buildAddOnsSection(order.addOns),
          16.h,
          _buildActionButton(order, controller),
          if (order.showWaitingText) ...[10.h, _buildWaitingText()],
        ],
      ),
    );
  }

  Widget _buildHotelHeader(String hotelName) {
    return Row(
      children: [
        SvgPicture.string(hotelNameSvg),
        10.w,
        text(text: hotelName, size: 14, fontWeight: FontWeight.w500, color: AppColor.black),
      ],
    );
  }

  Widget _buildOrderContent(OrderModel order, OrdersController controller) {
    return Row(
      children: [
        _buildOrderImage(order.imageUrl),
        16.w,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(order),
              6.h,
              _buildOrderCategory(order.itemCategory),
              _buildPriceAndStatus(order),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderImage(String imageUrl) {
    return image(url: imageUrl, height: 80, width: 80, borderRadius: BorderRadius.circular(10));
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: text(
            text: order.itemName,
            size: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.black,
            maxLines: 2,
            overFlow: TextOverflow.ellipsis,
          ),
        ),
        text(
          text: 'QTY : ${order.quantity}',
          size: 14,
          fontWeight: FontWeight.w500,
          color: AppColor.black.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _buildOrderCategory(String category) {
    return text(text: category, size: 14, fontWeight: FontWeight.w500, color: AppColor.black.withOpacity(0.6));
  }

  Widget _buildPriceAndStatus(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        text(
          text: 'Rs.${order.price.toStringAsFixed(0)}',
          size: 18,
          fontWeight: FontWeight.w500,
          color: AppColor.black,
        ),
        _buildStatusBadge(order.statusText),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: AppColor.appPrimary.withOpacity(0.2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          text(text: 'Status : ', size: 12, fontWeight: FontWeight.w500, color: AppColor.black),
          text(text: status, size: 12, fontWeight: FontWeight.w500, color: AppColor.appPrimary),
        ],
      ),
    );
  }

  Widget _buildDottedDivider() {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: DottedLinePainter(color: AppColor.black.withOpacity(0.1))),
    );
  }

  Widget _buildAddOnsSection(List<String> addOns) {
    return text(text: 'Add Ones (${addOns.length})', size: 16, fontWeight: FontWeight.w600, color: AppColor.black);
  }

  Widget _buildActionButton(OrderModel order, OrdersController controller) {
    final isRefreshButton = order.showRefreshButton;

    return button(
      name: isRefreshButton ? 'Refresh' : 'View Details',
      onTap: () {
        debugPrint('Button tapped for order ${order.id}, isRefreshButton: $isRefreshButton'); // Debug log
        if (isRefreshButton) {
          controller.refreshOrder(order.id);
        } else {
          controller.viewOrderDetails(order.id);
        }
      },
      height: 43,
      borderRadius: BorderRadius.circular(6),
      color: isRefreshButton ? AppColor.appPrimary : null, // Optional: different color for refresh
    );
  }

  Widget _buildWaitingText() {
    return Align(
      alignment: Alignment.center,
      child: text(text: 'Waiting for Restaurant Confirmation...', size: 12, fontWeight: FontWeight.w500),
    );
  }
}
