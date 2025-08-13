class OrderModel {
  final String id;
  final String hotelName;
  final String itemName;
  final String itemCategory;
  final String imageUrl;
  final double price;
  final int quantity;
  final OrderStatus status;
  final String orderType;
  final List<String> addOns;
  final DateTime orderDate;

  OrderModel({
    required this.id,
    required this.hotelName,
    required this.itemName,
    required this.itemCategory,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.status,
    required this.orderType,
    required this.addOns,
    required this.orderDate,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.outForDelivery:
        return 'Out for delivery';
      case OrderStatus.readyForPickup:
        return 'Ready for pickup';
      case OrderStatus.reserved:
        return 'Reserved';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isPending => status == OrderStatus.pending;
  bool get showWaitingText => isPending;
  bool get showRefreshButton => isPending;
}

enum OrderStatus { pending, confirmed, outForDelivery, readyForPickup, reserved, completed, cancelled }
