// models/food_item.dart
class FoodItem {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final String category;
  final String description;
  int quantity;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.description,
    this.quantity = 0,
  });

  double get totalPrice => price * quantity;
  bool get hasDiscount => originalPrice > price;
  double get discountPercentage => hasDiscount ? ((originalPrice - price) / originalPrice * 100) : 0;
}

// models/add_on.dart
class AddOn {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  bool isSelected;

  AddOn({required this.id, required this.name, required this.price, required this.imageUrl, this.isSelected = false});
}

// models/cart_item.dart
class CartItem {
  final FoodItem foodItem;
  final List<AddOn> selectedAddOns;
  int quantity;

  CartItem({required this.foodItem, required this.selectedAddOns, this.quantity = 1});

  double get totalPrice {
    double addOnPrice = selectedAddOns.fold(0, (sum, addOn) => sum + addOn.price);
    return (foodItem.price + addOnPrice) * quantity;
  }
}
