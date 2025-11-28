import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrebookDetailController extends GetxController {
  // Quantity tracking per foodId
  final Map<String, int> _foodQuantities = {};

  /// Get quantity for a specific food
  int getQuantity(String foodId) {
    return _foodQuantities[foodId] ?? 0;
  }

  /// Increment quantity for a food
  void incrementQuantity(String foodId) {
    _foodQuantities[foodId] = (getQuantity(foodId)) + 1;
    debugPrint('✅ Prebook Detail - Quantity incremented for $foodId: ${_foodQuantities[foodId]}');
    update(['prebook_quantity_$foodId']);
  }

  /// Decrement quantity for a food
  void decrementQuantity(String foodId) {
    final currentQuantity = getQuantity(foodId);
    if (currentQuantity > 0) {
      _foodQuantities[foodId] = currentQuantity - 1;
      debugPrint('✅ Prebook Detail - Quantity decremented for $foodId: ${_foodQuantities[foodId]}');
      update(['prebook_quantity_$foodId']);
    }
  }

  /// Add to cart with logging
  void addToCart(String foodId) {
    final quantity = getQuantity(foodId);
    debugPrint('🛒 Prebook Detail - Add to Cart - FoodId: $foodId, Quantity: $quantity');
    // Cart implementation will be added later
  }

  /// Clear all quantities
  void clearQuantities() {
    _foodQuantities.clear();
    debugPrint('🗑️ Prebook Detail - All quantities cleared');
  }

  /// Reset specific food quantity
  void resetQuantity(String foodId) {
    _foodQuantities[foodId] = 0;
    debugPrint('🔄 Prebook Detail - Quantity reset for $foodId');
    update(['prebook_quantity_$foodId']);
  }
}
