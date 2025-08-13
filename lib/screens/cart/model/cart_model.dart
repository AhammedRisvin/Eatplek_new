// cart_item_model.dart
class CartItem {
  final String id;
  final String name;
  final String category;
  final double basePrice;
  final String imageUrl;
  int quantity;
  List<AddOn> selectedAddOns;
  String? instructions;

  CartItem({
    required this.id,
    required this.name,
    required this.category,
    required this.basePrice,
    required this.imageUrl,
    required this.quantity,
    required this.selectedAddOns,
    this.instructions,
  });

  double get totalItemPrice {
    double addOnPrice = selectedAddOns.fold(0, (sum, addOn) => sum + addOn.price);
    return (basePrice + addOnPrice) * quantity;
  }

  CartItem copyWith({
    String? id,
    String? name,
    String? category,
    double? basePrice,
    String? imageUrl,
    int? quantity,
    List<AddOn>? selectedAddOns,
    String? instructions,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      selectedAddOns: selectedAddOns ?? this.selectedAddOns,
      instructions: instructions ?? this.instructions,
    );
  }
}

// add_on_model.dart
class AddOn {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  bool isSelected;

  AddOn({required this.id, required this.name, required this.price, required this.imageUrl, required this.isSelected});

  AddOn copyWith({String? id, String? name, double? price, String? imageUrl, bool? isSelected}) {
    return AddOn(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

// promo_code_model.dart
class PromoCode {
  final String code;
  final String description;
  final double discountAmount;
  final double discountPercentage;
  final double minimumOrderValue;
  final bool isActive;
  final DateTime expiryDate;

  PromoCode({
    required this.code,
    required this.description,
    required this.discountAmount,
    required this.discountPercentage,
    required this.minimumOrderValue,
    required this.isActive,
    required this.expiryDate,
  });

  bool get isValid {
    return isActive && DateTime.now().isBefore(expiryDate);
  }
}
