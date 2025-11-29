import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Service to manage cart state globally
/// Both CartController and RestaurantDetailViewController listen to this
class CartService extends GetxService {
  // Cart items from API (source of truth)
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  // Local maps for quick access
  final RxMap<String, int> cartFoodQuantity = <String, int>{}.obs;
  final RxMap<String, Map<String, int>> cartCustomizationQuantity = <String, Map<String, int>>{}.obs;
  final RxMap<String, Map<String, int>> cartAddOnQuantity = <String, Map<String, int>>{}.obs;

  // Cart totals
  final RxInt itemCount = 0.obs;
  final RxDouble totalPrice = 0.0.obs;

  /// Update cart state from API response
  void updateCartFromApi(Map<String, dynamic> cartData) {
    try {
      debugPrint('🔄 CartService: Updating cart from API response');

      // Extract items
      if (cartData['items'] != null) {
        cartItems.value = List<Map<String, dynamic>>.from(cartData['items']);
        debugPrint('📊 CartService: ${cartItems.length} items in cart');
      }

      // Update local maps
      cartFoodQuantity.clear();
      cartCustomizationQuantity.clear();
      cartAddOnQuantity.clear();

      for (var item in cartItems) {
        final foodId = item['foodId'] ?? '';
        if (foodId.isEmpty) continue;

        final hasCustomizations = item['customizations'] != null && (item['customizations'] as List).isNotEmpty;

        if (!hasCustomizations) {
          // Scenario 1 & 2: Food + optional add-ons
          cartFoodQuantity[foodId] = item['quantity'] ?? 1;

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              cartAddOnQuantity[foodId]![addOn['addOnId']] = addOn['quantity'] ?? 0;
            }
          }
        } else {
          // Scenario 3 & 4: Customizations + optional add-ons
          cartCustomizationQuantity[foodId] = {};
          for (var custom in item['customizations'] as List) {
            cartCustomizationQuantity[foodId]![custom['customizationId']] = custom['quantity'] ?? 0;
          }

          if (item['addOns'] != null && (item['addOns'] as List).isNotEmpty) {
            cartAddOnQuantity[foodId] = {};
            for (var addOn in item['addOns'] as List) {
              cartAddOnQuantity[foodId]![addOn['addOnId']] = addOn['quantity'] ?? 0;
            }
          }
        }
      }

      // Update totals
      if (cartData['totals'] != null) {
        itemCount.value = cartData['totals']['itemCount'] ?? 0;
        totalPrice.value = (cartData['totals']['grandTotal'] ?? 0).toDouble();
      }

      debugPrint('✅ CartService: Cart state synchronized');
    } catch (e) {
      debugPrint('❌ CartService: Error updating cart - $e');
    }
  }

  /// Clear cart
  void clearCart() {
    cartItems.clear();
    cartFoodQuantity.clear();
    cartCustomizationQuantity.clear();
    cartAddOnQuantity.clear();
    itemCount.value = 0;
    totalPrice.value = 0.0;
  }

  /// Check if food is in cart
  bool isFoodInCart(String foodId) {
    return cartItems.any((item) => item['foodId'] == foodId);
  }

  /// Get food quantity from cart
  int getFoodQuantity(String foodId) {
    return cartFoodQuantity[foodId] ?? 0;
  }

  /// Get customization quantities for a food
  Map<String, int> getCustomizationQuantities(String foodId) {
    return cartCustomizationQuantity[foodId] ?? {};
  }

  /// Get add-on quantities for a food
  Map<String, int> getAddOnQuantities(String foodId) {
    return cartAddOnQuantity[foodId] ?? {};
  }

  /// Check if food has customizations in cart
  bool foodHasCustomizations(String foodId) {
    return cartCustomizationQuantity.containsKey(foodId) && cartCustomizationQuantity[foodId]!.isNotEmpty;
  }
}
