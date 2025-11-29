import 'dart:async';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../model/cart_api_model.dart';
import 'cart_service.dart';

class CartController extends GetxController {
  final FittorConnect _apiClient = FittorConnect();
  final CartService _cartService = Get.find<CartService>();

  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  CartModel? cartModel;

  final TextEditingController instructionsController = TextEditingController();
  String _instructionsError = '';
  String get instructionsError => _instructionsError;

  final TextEditingController promoCodeController = TextEditingController();
  String _promoCodeError = '';
  String get promoCodeError => _promoCodeError;
  String _appliedPromoCode = '';
  String get appliedPromoCode => _appliedPromoCode;
  final double _promoDiscount = 0.0;
  double get promoDiscount => _promoDiscount;

  Timer? _quantityDebounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  List<CartItem> get cartItems {
    try {
      if (cartModel?.data?.items != null) {
        return cartModel!.data!.items!;
      }
    } catch (e) {
      debugPrint('Error getting cart items: $e');
    }
    return [];
  }

  bool get isCartEmpty => cartItems.isEmpty;

  @override
  void onInit() {
    super.onInit();
    _fetchCartData();
    _listenToCartServiceUpdates();
  }

  void _listenToCartServiceUpdates() {
    ever(_cartService.cartItems, (_) {
      _syncCartModelWithService();
      update(['cart_items', 'price_summary', 'empty_cart']);
    });

    ever(_cartService.totalPrice, (_) {
      update(['price_summary']);
    });

    ever(_cartService.itemCount, (_) {
      update(['price_summary', 'empty_cart']);
    });
  }

  void _syncCartModelWithService() {
    try {
      if (_cartService.cartItems.isNotEmpty) {
        final convertedItems = _convertToCartItems(_cartService.cartItems);

        cartModel = CartModel(
          success: true,
          message: 'Cart updated',
          data: CartData(
            items: convertedItems,
            totals:
                cartModel?.data?.totals != null
                    ? Totals(
                      subTotal: cartModel!.data!.totals!.subTotal ?? 0,
                      addOnTotal: cartModel!.data!.totals!.addOnTotal ?? 0,
                      customizationTotal: cartModel!.data!.totals!.customizationTotal ?? 0,
                      packingChargeTotal: cartModel!.data!.totals!.packingChargeTotal ?? 0,
                      discountTotal: cartModel!.data!.totals!.discountTotal ?? 0,
                      couponDiscount: cartModel!.data!.totals!.couponDiscount ?? 0,
                      taxAmount: cartModel!.data!.totals!.taxAmount ?? 0,
                      taxPercentage: cartModel!.data!.totals!.taxPercentage ?? 0,
                      grandTotal: _cartService.totalPrice.value,
                      itemCount: _cartService.itemCount.value,
                    )
                    : Totals(
                      subTotal: 0,
                      addOnTotal: 0,
                      customizationTotal: 0,
                      packingChargeTotal: 0,
                      discountTotal: 0,
                      couponDiscount: 0,
                      taxAmount: 0,
                      taxPercentage: 0,
                      grandTotal: _cartService.totalPrice.value,
                      itemCount: _cartService.itemCount.value,
                    ),
          ),
        );
      } else {
        cartModel = null;
      }
    } catch (e) {
      debugPrint('Error syncing cart model: $e');
    }
  }

  List<CartItem> _convertToCartItems(List<Map<String, dynamic>> items) {
    return items.map((item) {
      return CartItem(
        foodId: item['foodId'],
        foodName: item['foodName'],
        foodImage: item['foodImage'],
        quantity: item['quantity'] ?? 1,
        basePrice: (item['basePrice'] ?? 0).toDouble(),
        effectivePrice: (item['effectivePrice'] ?? 0).toDouble(),
        customizations:
            (item['customizations'] as List?)?.map((c) {
              return AddOn(
                customizationId: c['customizationId'],
                name: c['name'],
                price: c['price'],
                quantity: c['quantity'],
                addOnId: c['customizationId'],
              );
            }).toList(),
        addOns:
            (item['addOns'] as List?)?.map((a) {
              return AddOn(addOnId: a['addOnId'], name: a['name'], price: a['price'], quantity: a['quantity']);
            }).toList(),
        itemTotal: (item['itemTotal'] ?? 0).toDouble(),
      );
    }).toList();
  }

  Future<void> _fetchCartData() async {
    try {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      update(['cart_items', 'price_summary', 'empty_cart']);

      final response = await _apiClient.get(endpoint: Urls.getCartUrl);

      if (response != null && response is Map<String, dynamic>) {
        cartModel = CartModel.fromJson(response);

        if (cartModel?.success == true && cartModel?.data != null) {
          _cartService.updateCartFromApi({
            'items': cartModel!.data!.items?.map((item) => _convertCartItemToMap(item)).toList() ?? [],
            'totals': {
              'itemCount': cartModel!.data!.totals?.itemCount ?? 0,
              'grandTotal': cartModel!.data!.totals?.grandTotal ?? 0,
              'subTotal': cartModel!.data!.totals?.subTotal ?? 0,
              'taxAmount': cartModel!.data!.totals?.taxAmount ?? 0,
              'taxPercentage': cartModel!.data!.totals?.taxPercentage ?? 0,
              'packingChargeTotal': cartModel!.data!.totals?.packingChargeTotal ?? 0,
              'discountTotal': cartModel!.data!.totals?.discountTotal ?? 0,
              'couponDiscount': cartModel!.data!.totals?.couponDiscount ?? 0,
            },
          });

          hasError = false;
          isLoading = false;
        } else {
          hasError = true;
          errorMessage = cartModel?.message ?? 'Failed to load cart';
          isLoading = false;
        }
      } else {
        hasError = true;
        errorMessage = 'Invalid response format';
        isLoading = false;
      }

      update(['cart_items', 'price_summary', 'empty_cart']);
    } catch (e) {
      hasError = true;
      errorMessage = 'Error loading cart: $e';
      isLoading = false;
      update(['cart_items', 'price_summary', 'empty_cart']);
      debugPrint('Error fetching cart: $e');
    }
  }

  Map<String, dynamic> _convertCartItemToMap(CartItem item) {
    return {
      'foodId': item.foodId,
      'foodName': item.foodName,
      'foodImage': item.foodImage,
      'quantity': item.quantity ?? 1,
      'basePrice': item.effectivePrice ?? item.basePrice ?? 0,
      'customizations':
          item.customizations
              ?.map(
                (c) => {'customizationId': c.customizationId, 'name': c.name, 'price': c.price, 'quantity': c.quantity},
              )
              .toList() ??
          [],
      'addOns':
          item.addOns
              ?.map((a) => {'addOnId': a.addOnId, 'name': a.name, 'price': a.price, 'quantity': a.quantity})
              .toList() ??
          [],
      'itemTotal': item.itemTotal ?? 0,
    };
  }

  int _detectScenario(CartItem item) {
    final hasCustomizations = item.customizations != null && item.customizations!.isNotEmpty;
    final hasAddOns = item.addOns != null && item.addOns!.isNotEmpty;

    if (!hasCustomizations && !hasAddOns) {
      return 1;
    } else if (!hasCustomizations && hasAddOns) {
      return 2;
    } else if (hasCustomizations && !hasAddOns) {
      return 3;
    } else {
      return 4;
    }
  }

  Future<void> updateItemQuantity(String foodId, int newQuantity, {String? customizationId, String? addOnId}) async {
    try {
      final itemIndex = cartItems.indexWhere((item) => item.foodId == foodId);
      if (itemIndex == -1) return;

      final item = cartItems[itemIndex];
      final scenario = _detectScenario(item);

      final requestBody = _buildUpdateRequestBody(foodId, item, scenario, newQuantity, customizationId, addOnId);

      if (requestBody == null) return;

      final response = await _apiClient.post(endpoint: Urls.addOrUpdateCartUrl, data: requestBody);

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          _cartService.updateCartFromApi({
            'items': response['data']['items'] ?? [],
            'totals': response['data']['totals'] ?? {},
          });
        } else {
          Get.snackbar('Error', response['message'] ?? 'Failed to update cart');
        }
      }
    } catch (e) {
      debugPrint('Exception while updating item: $e');
      Get.snackbar('Error', 'Failed to update cart');
    }
  }

  Map<String, dynamic>? _buildUpdateRequestBody(
    String foodId,
    CartItem item,
    int scenario,
    int newQuantity,
    String? customizationId,
    String? addOnId,
  ) {
    final serviceType = _getCleanServiceType(Store.deliveryPreference);

    if (scenario == 1) {
      return {'foodId': foodId, 'quantity': newQuantity, 'serviceType': serviceType};
    } else if (scenario == 2) {
      if (customizationId == null && addOnId == null) {
        return {
          'foodId': foodId,
          'quantity': newQuantity,
          'serviceType': serviceType,
          'addOns': _buildAddOnsArray(item),
        };
      } else if (addOnId != null) {
        return {
          'foodId': foodId,
          'quantity': item.quantity ?? 1,
          'serviceType': serviceType,
          'addOns': _buildUpdatedAddOnsArray(item, addOnId, newQuantity),
        };
      }
    } else if (scenario == 3) {
      if (customizationId != null) {
        return {
          'foodId': foodId,
          'quantity': 1,
          'serviceType': serviceType,
          'customizations': _buildUpdatedCustomizationsArray(item, customizationId, newQuantity),
        };
      }
    } else if (scenario == 4) {
      if (customizationId != null) {
        return {
          'foodId': foodId,
          'quantity': 1,
          'serviceType': serviceType,
          'customizations': _buildUpdatedCustomizationsArray(item, customizationId, newQuantity),
          'addOns': _buildAddOnsArray(item),
        };
      } else if (addOnId != null) {
        return {
          'foodId': foodId,
          'quantity': 1,
          'serviceType': serviceType,
          'customizations': _buildCustomizationsArray(item),
          'addOns': _buildUpdatedAddOnsArray(item, addOnId, newQuantity),
        };
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _buildAddOnsArray(CartItem item) {
    if (item.addOns == null || item.addOns!.isEmpty) return [];
    return item.addOns!.map((addOn) => {'addOnId': addOn.addOnId, 'quantity': addOn.quantity ?? 0}).toList();
  }

  List<Map<String, dynamic>> _buildUpdatedAddOnsArray(CartItem item, String addOnId, int newQuantity) {
    if (item.addOns == null || item.addOns!.isEmpty) return [];
    return item.addOns!.map((addOn) {
      return {'addOnId': addOn.addOnId, 'quantity': addOn.addOnId == addOnId ? newQuantity : (addOn.quantity ?? 0)};
    }).toList();
  }

  List<Map<String, dynamic>> _buildCustomizationsArray(CartItem item) {
    if (item.customizations == null || item.customizations!.isEmpty) return [];
    return item.customizations!
        .map((custom) => {'customizationId': custom.customizationId, 'quantity': custom.quantity ?? 0})
        .toList();
  }

  List<Map<String, dynamic>> _buildUpdatedCustomizationsArray(CartItem item, String customizationId, int newQuantity) {
    if (item.customizations == null || item.customizations!.isEmpty) return [];
    return item.customizations!.map((custom) {
      return {
        'customizationId': custom.customizationId,
        'quantity': custom.customizationId == customizationId ? newQuantity : (custom.quantity ?? 0),
      };
    }).toList();
  }

  void removeItem(String itemId) {
    final items = _cartService.cartItems.where((item) => item['foodId'] != itemId).toList();
    _cartService.cartItems.value = items;
    update(['cart_items', 'price_summary', 'empty_cart']);
  }

  double get subtotal {
    if (cartModel?.data?.totals != null) {
      return cartModel!.data!.totals!.subTotal ?? 0;
    }
    return 0;
  }

  double get deliveryFee {
    return 0.0;
  }

  double get taxAmount {
    if (cartModel?.data?.totals != null) {
      return cartModel!.data!.totals!.taxAmount ?? 0;
    }
    return 0;
  }

  int get taxPercentageValue {
    if (cartModel?.data?.totals != null) {
      return cartModel!.data!.totals!.taxPercentage ?? 0;
    }
    return 0;
  }

  double get packingCharge {
    if (cartModel?.data?.totals != null) {
      return (cartModel!.data!.totals!.packingChargeTotal ?? 0).toDouble();
    }
    return 0;
  }

  double get discountAmount {
    if (cartModel?.data?.totals != null) {
      return (cartModel!.data!.totals!.discountTotal ?? 0).toDouble();
    }
    return 0;
  }

  double get couponDiscount {
    if (cartModel?.data?.totals != null) {
      return (cartModel!.data!.totals!.couponDiscount ?? 0).toDouble();
    }
    return 0;
  }

  double get totalAmount {
    return _cartService.totalPrice.value;
  }

  int get itemCount {
    return _cartService.itemCount.value;
  }

  bool validateInstructions() {
    final instructions = instructionsController.text.trim();

    if (instructions.isNotEmpty && instructions.length < 10) {
      _instructionsError = 'Instructions must be at least 10 characters';
      update(['instructions_validation']);
      return false;
    }

    if (instructions.length > 200) {
      _instructionsError = 'Instructions cannot exceed 200 characters';
      update(['instructions_validation']);
      return false;
    }

    _instructionsError = '';
    update(['instructions_validation']);
    return true;
  }

  void clearInstructionsError() {
    if (_instructionsError.isNotEmpty) {
      _instructionsError = '';
      update(['instructions_validation']);
    }
  }

  void applyPromoCode() {
    final code = promoCodeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _promoCodeError = 'Please enter a promo code';
      update(['promo_validation']);
      return;
    }

    _appliedPromoCode = code;
    _promoCodeError = '';
    promoCodeController.text = code;

    update(['promo_validation', 'price_summary']);

    Get.snackbar('Success', 'Promo code applied!', snackPosition: SnackPosition.BOTTOM);
  }

  void removePromoCode() {
    _appliedPromoCode = '';
    _promoCodeError = '';
    promoCodeController.clear();
    update(['promo_validation', 'price_summary']);
  }

  void formatPromoCode(String value) {
    final upperCaseValue = value.toUpperCase();
    if (promoCodeController.text != upperCaseValue) {
      promoCodeController.value = promoCodeController.value.copyWith(
        text: upperCaseValue,
        selection: TextSelection.collapsed(offset: upperCaseValue.length),
      );
    }
    clearPromoError();
  }

  void clearPromoError() {
    if (_promoCodeError.isNotEmpty) {
      _promoCodeError = '';
      update(['promo_validation']);
    }
  }

  String _getCleanServiceType(String servicePreference) {
    String cleaned = servicePreference.toLowerCase().trim();

    if (cleaned.contains('delivery') || cleaned.contains('🛵')) {
      return 'delivery';
    } else if (cleaned.contains('dine-in') || cleaned.contains('dine in') || cleaned.contains('🍽')) {
      return 'dine-in';
    } else if (cleaned.contains('takeaway') || cleaned.contains('🎁')) {
      return 'takeaway';
    } else if (cleaned.contains('car-dine') || cleaned.contains('car dine') || cleaned.contains('🚗')) {
      return 'car-dine-in';
    }

    return 'delivery';
  }

  void placeOrder() {
    if (!validateInstructions()) {
      return;
    }

    if (cartItems.isEmpty) {
      Get.snackbar('Empty Cart', 'Please add items to cart before placing order', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.snackbar(
      'Order Placed',
      'Your order has been placed successfully!',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );

    Get.toNamed(Routes.orderConfirmationView);
  }

  void retryFetchCart() {
    _fetchCartData();
  }

  @override
  void onClose() {
    _quantityDebounceTimer?.cancel();
    instructionsController.dispose();
    promoCodeController.dispose();
    super.onClose();
  }
}
