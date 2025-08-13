import 'package:eatplek_app/core/routes/routes.dart';
import 'package:get/get.dart';

import '../../restaurant_detail_view/model/food_add_on_model.dart';

class FoodDetailsViewController extends GetxController {
  // Food quantity
  int _quantity = 0;
  int get quantity => _quantity;

  // Base food price
  final double _basePrice = 299.0;

  // Available add-ons
  final List<AddOn> _availableAddOns = [
    AddOn(
      id: '1',
      name: 'Extra Cheese',
      price: 25.0,
      imageUrl: 'https://picsum.photos/100/100?random=1',
      isSelected: false,
    ),
    AddOn(
      id: '2',
      name: 'Crispy Bacon',
      price: 45.0,
      imageUrl: 'https://picsum.photos/100/100?random=2',
      isSelected: false,
    ),
    AddOn(
      id: '3',
      name: 'Avocado Slice',
      price: 35.0,
      imageUrl: 'https://picsum.photos/100/100?random=3',
      isSelected: false,
    ),
    AddOn(
      id: '4',
      name: 'Spicy Mayo',
      price: 15.0,
      imageUrl: 'https://picsum.photos/100/100?random=4',
      isSelected: false,
    ),
    AddOn(
      id: '5',
      name: 'Grilled Mushrooms',
      price: 30.0,
      imageUrl: 'https://picsum.photos/100/100?random=5',
      isSelected: false,
    ),
  ];

  List<AddOn> get availableAddOns => _availableAddOns;

  // Quantity controls
  void incrementQuantity() {
    if (_quantity < 10) {
      _quantity++;
      update(['quantity', 'cart']);
    }
  }

  void decrementQuantity() {
    if (_quantity > 0) {
      _quantity--;
      update(['quantity', 'cart']);
    }
  }

  // Add-on controls
  void toggleAddOn(String addOnId) {
    final index = _availableAddOns.indexWhere((addOn) => addOn.id == addOnId);
    if (index != -1) {
      _availableAddOns[index].isSelected = !_availableAddOns[index].isSelected;

      // Auto-increment quantity to 1 if it's 0 and an add-on is selected
      if (_availableAddOns[index].isSelected && _quantity == 0) {
        _quantity = 1;
        update(['addons', 'cart', 'quantity']);
      } else {
        update(['addons', 'cart']);
      }
    }
  }

  // Price calculation
  double getTotalPrice() {
    if (_quantity == 0) return _basePrice; // Show base price even when quantity is 0

    double addOnPrice = 0;
    for (var addOn in _availableAddOns) {
      if (addOn.isSelected) {
        addOnPrice += addOn.price;
      }
    }
    return (_basePrice + addOnPrice) * _quantity;
  }

  // Get selected add-ons for cart display
  List<AddOn> getSelectedAddOns() {
    return _availableAddOns.where((addOn) => addOn.isSelected).toList();
  }

  // Add to cart
  void addToCart() {
    if (_quantity <= 0) {
      Get.snackbar(
        'Invalid Quantity',
        'Please select at least 1 item to add to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    final selectedAddOns = getSelectedAddOns();
    String addOnsText = selectedAddOns.isNotEmpty ? ' with ${selectedAddOns.map((e) => e.name).join(', ')}' : '';

    Get.snackbar(
      'Added to Cart',
      '${_quantity}x Classic Chicken Burger$addOnsText added to cart for ₹${getTotalPrice().toInt()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: Duration(seconds: 3),
    );

    // You can add actual cart logic here
    // For example: Get.find<CartController>().addItem(...)
    Get.toNamed(Routes.cartView);
  }

  // Reset all selections (useful when navigating away)
  void resetSelections() {
    _quantity = 0;
    for (var addOn in _availableAddOns) {
      addOn.isSelected = false;
    }
    update(['quantity', 'cart', 'addons']);
  }

  @override
  void onClose() {
    // Clean up when controller is disposed
    super.onClose();
  }
}
