import 'package:eatplek_app/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/orders_model.dart';

class OrdersController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  List<OrderModel> deliveryOrders = [];
  List<OrderModel> takeawayOrders = [];
  List<OrderModel> diningOrders = [];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    _generateDummyData();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void _generateDummyData() {
    // Generate delivery orders with mixed statuses
    deliveryOrders = List.generate(10, (index) {
      return OrderModel(
        id: 'DEL${index + 1}',
        hotelName: 'Restaurant ${index + 1}',
        itemName: 'Classic Chicken Burger',
        itemCategory: 'Burger',
        imageUrl: 'https://picsum.photos/250?image=${30 + index}',
        price: 180.0 + (index * 20),
        quantity: 1,
        status: index.isEven ? OrderStatus.pending : OrderStatus.outForDelivery,
        orderType: 'Delivery',
        addOns: ['Extra Cheese', 'Spicy Sauce'],
        orderDate: DateTime.now().subtract(Duration(hours: index)),
      );
    });

    // Generate takeaway orders
    takeawayOrders = List.generate(8, (index) {
      return OrderModel(
        id: 'TAK${index + 1}',
        hotelName: 'Restaurant ${index + 1}',
        itemName: 'Grilled Chicken',
        itemCategory: 'Main Course',
        imageUrl: 'https://picsum.photos/250?image=${40 + index}',
        price: 250.0 + (index * 15),
        quantity: 1,
        status: OrderStatus.readyForPickup,
        orderType: 'Takeaway',
        addOns: ['Garlic Bread'],
        orderDate: DateTime.now().subtract(Duration(hours: index + 2)),
      );
    });

    // Generate dining orders
    diningOrders = List.generate(5, (index) {
      return OrderModel(
        id: 'DIN${index + 1}',
        hotelName: 'Restaurant ${index + 1}',
        itemName: 'Pasta Carbonara',
        itemCategory: 'Pasta',
        imageUrl: 'https://picsum.photos/250?image=${50 + index}',
        price: 320.0 + (index * 25),
        quantity: 1,
        status: OrderStatus.reserved,
        orderType: 'Dining',
        addOns: ['Extra Parmesan', 'Garlic Bread'],
        orderDate: DateTime.now().subtract(Duration(hours: index + 1)),
      );
    });
  }

  List<OrderModel> getOrdersByType(String type) {
    switch (type.toLowerCase()) {
      case 'delivery':
        return deliveryOrders;
      case 'takeaway':
        return takeawayOrders;
      case 'dining':
        return diningOrders;
      default:
        return [];
    }
  }

  void refreshOrder(String orderId) {
    debugPrint('Refreshing order: $orderId'); // Debug log

    // Find and update the order status in delivery orders
    final deliveryIndex = deliveryOrders.indexWhere((order) => order.id == orderId);
    if (deliveryIndex != -1) {
      final currentOrder = deliveryOrders[deliveryIndex];

      // Create new order with updated status
      deliveryOrders[deliveryIndex] = OrderModel(
        id: currentOrder.id,
        hotelName: currentOrder.hotelName,
        itemName: currentOrder.itemName,
        itemCategory: currentOrder.itemCategory,
        imageUrl: currentOrder.imageUrl,
        price: currentOrder.price,
        quantity: currentOrder.quantity,
        status: OrderStatus.outForDelivery, // Update status from pending to out for delivery
        orderType: currentOrder.orderType,
        addOns: currentOrder.addOns,
        orderDate: currentOrder.orderDate,
      );

      debugPrint('Order status updated to: ${deliveryOrders[deliveryIndex].statusText}'); // Debug log

      // Update the specific order card and the entire delivery list
      update(['order_card_$orderId', 'delivery_orders']);

      // Show success message
      Get.snackbar(
        'Order Updated',
        'Order status has been refreshed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      debugPrint('Order not found: $orderId'); // Debug log
    }
  }

  void viewOrderDetails(String orderId) {
    Get.toNamed(Routes.orderDetailsView);
  }
}
