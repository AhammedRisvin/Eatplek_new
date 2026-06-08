import 'dart:async';
import 'dart:developer';

import 'package:eatplek_app/core/network/api_endpoints.dart';
import 'package:eatplek_app/core/routes/routes.dart';
import 'package:eatplek_app/core/util/service_type.dart';
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

  bool isPromoApplying = false;

  Timer? _quantityDebounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  // ── Public getter so CartExtrasController can access _cartService ─────────
  CartService get cartService => _cartService;

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
    // ✅ DO NOT call _fetchCartData() here.
    // CartView is mounted inside IndexedStack at app start even when not visible.
    // Fetching here would fire the cart API on every app launch regardless of screen.
    // CartView.initState() calls fetchCartData() explicitly when user opens cart.
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

  // ── Called by CartService._silentPoll() when a poll detects a change ──────
  /// Re-parses the full API response into cartModel so CartView reflects
  /// fresh vendor, coupon, items, and totals without a full isLoading cycle.
  void syncFromPoll(Map<String, dynamic> freshResponse) {
    try {
      final fresh = CartModel.fromJson(freshResponse);
      if (fresh.success != true || fresh.data == null) return;

      // Preserve vendor if the fresh response omits it (shouldn't happen,
      // but defensive)
      cartModel = CartModel(
        success: fresh.success,
        message: fresh.message,
        data: CartData(
          id: fresh.data!.id,
          cartCode: fresh.data!.cartCode,
          user: fresh.data!.user,
          serviceType: fresh.data!.serviceType,
          isPrebookCart: fresh.data!.isPrebookCart,
          vendor: fresh.data!.vendor ?? cartModel?.data?.vendor,
          items: fresh.data!.items,
          couponCode: fresh.data!.couponCode,
          totals: fresh.data!.totals,
          lastUpdatedAt: fresh.data!.lastUpdatedAt,
          isCartOwner: fresh.data!.isCartOwner,
          friendInvitations: fresh.data!.friendInvitations,
        ),
      );

      // Sync coupon state
      final freshCoupon = fresh.data!.couponCode;
      if (freshCoupon != null && freshCoupon.isNotEmpty) {
        _appliedPromoCode = freshCoupon;
        promoCodeController.text = freshCoupon;
      } else {
        _appliedPromoCode = '';
        promoCodeController.clear();
      }

      update([
        'cart_items',
        'price_summary',
        'empty_cart',
        'promo_validation',
        'friend_invitations',
      ]);

      debugPrint('✅ CartController.syncFromPoll: cartModel updated from poll');
    } catch (e) {
      debugPrint('⚠️ CartController.syncFromPoll error (ignored): $e');
    }
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
            vendor: cartModel?.data?.vendor,
            couponCode: cartModel?.data?.couponCode,
            isCartOwner: cartModel?.data?.isCartOwner,
            friendInvitations: cartModel?.data?.friendInvitations,
            totals:
                cartModel?.data?.totals != null
                    ? Totals(
                      subTotal: cartModel!.data!.totals!.subTotal ?? 0,
                      addOnTotal: cartModel!.data!.totals!.addOnTotal ?? 0,
                      customizationTotal:
                          cartModel!.data!.totals!.customizationTotal ?? 0,
                      packingChargeTotal:
                          cartModel!.data!.totals!.packingChargeTotal ?? 0,
                      discountTotal:
                          cartModel!.data!.totals!.discountTotal ?? 0,
                      couponDiscount:
                          cartModel!.data!.totals!.couponDiscount ?? 0,
                      taxAmount: cartModel!.data!.totals!.taxAmount ?? 0,
                      taxPercentage:
                          cartModel!.data!.totals!.taxPercentage ?? 0,
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
        id: item['id'],
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
                price: (c['price'] ?? 0).toDouble(),
                quantity: c['quantity'],
                addOnId: c['customizationId'],
              );
            }).toList(),
        addOns:
            (item['addOns'] as List?)?.map((a) {
              return AddOn(
                addOnId: a['addOnId'],
                name: a['name'],
                price: (a['price'] ?? 0).toDouble(),
                quantity: a['quantity'],
              );
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

      debugPrint('═════════════════════════════════════════════════════════');
      debugPrint('🔍 CART API RAW RESPONSE DEBUG');
      debugPrint('═════════════════════════════════════════════════════════');
      debugPrint('Full Response Type: ${response.runtimeType}');
      log('Full Response: $response');

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('\n📋 RESPONSE STRUCTURE:');
        debugPrint('Top-level Keys: ${response.keys.toList()}');

        if (response.containsKey('data')) {
          final data = response['data'];
          debugPrint('\n📦 DATA STRUCTURE:');
          debugPrint('Data Type: ${data.runtimeType}');
          debugPrint('Data is Map: ${data is Map}');

          if (data is Map<String, dynamic>) {
            debugPrint('Data Keys: ${data.keys.toList()}');

            debugPrint('\n🏪 VENDOR CHECKING:');
            debugPrint('Has vendor key: ${data.containsKey('vendor')}');

            if (data.containsKey('vendor')) {
              final vendor = data['vendor'];
              debugPrint('Vendor Type: ${vendor.runtimeType}');
              debugPrint('Vendor is null: ${vendor == null}');
              debugPrint('Vendor Value: $vendor');

              if (vendor is Map) {
                debugPrint('Vendor Keys: ${vendor.keys.toList()}');
                debugPrint('Vendor Name: ${vendor['name']}');
                debugPrint('Vendor ID: ${vendor['id']}');
              }
            } else {
              debugPrint('❌ VENDOR KEY NOT FOUND IN RESPONSE');
              debugPrint('Available keys: ${data.keys.join(", ")}');
            }

            debugPrint('\n📍 ITEMS CHECKING:');
            debugPrint('Has items key: ${data.containsKey('items')}');
            if (data.containsKey('items')) {
              final items = data['items'];
              debugPrint('Items Type: ${items.runtimeType}');
              debugPrint(
                'Items Count: ${items is List ? (items).length : "N/A"}',
              );
            }

            debugPrint('\n💰 TOTALS CHECKING:');
            debugPrint('Has totals key: ${data.containsKey('totals')}');
            if (data.containsKey('totals')) {
              final totals = data['totals'];
              debugPrint('Totals Type: ${totals.runtimeType}');
              if (totals is Map) {
                debugPrint('Totals Keys: ${totals.keys.toList()}');
              }
            }
          }
        } else {
          debugPrint('❌ No data key in response');
        }
      }

      debugPrint('═════════════════════════════════════════════════════════\n');

      if (response != null && response is Map<String, dynamic>) {
        cartModel = CartModel.fromJson(response);

        debugPrint('📦 PARSED MODEL DEBUG');
        debugPrint('CartModel success: ${cartModel?.success}');
        debugPrint('CartModel data exists: ${cartModel?.data != null}');
        debugPrint('CartModel vendor: ${cartModel?.data?.vendor}');
        debugPrint('CartModel vendor name: ${cartModel?.data?.vendor?.name}');
        debugPrint('CartModel couponCode: ${cartModel?.data?.couponCode}');
        debugPrint(
          '═════════════════════════════════════════════════════════\n',
        );

        if (cartModel?.success == true && cartModel?.data != null) {
          final snapshotItems =
              cartModel!.data!.items
                  ?.map((item) => _convertCartItemToMap(item))
                  .toList() ??
              [];
          final snapshotTotals = cartModel!.data!.totals;
          final snapshotCouponCode = cartModel!.data!.couponCode;

          _cartService.updateCartFromApi({
            'items': snapshotItems,
            'totals': {
              'itemCount': snapshotTotals?.itemCount ?? 0,
              'grandTotal': snapshotTotals?.grandTotal ?? 0,
              'subTotal': snapshotTotals?.subTotal ?? 0,
              'taxAmount': snapshotTotals?.taxAmount ?? 0,
              'taxPercentage': snapshotTotals?.taxPercentage ?? 0,
              'packingChargeTotal': snapshotTotals?.packingChargeTotal ?? 0,
              'discountTotal': snapshotTotals?.discountTotal ?? 0,
              'couponDiscount': snapshotTotals?.couponDiscount ?? 0,
            },
          });

          if (snapshotCouponCode != null && snapshotCouponCode.isNotEmpty) {
            _appliedPromoCode = snapshotCouponCode;
            promoCodeController.text = snapshotCouponCode;
            _promoCodeError = '';
            debugPrint(
              '🎟️ Restored applied coupon from API: $snapshotCouponCode',
            );
          } else {
            _appliedPromoCode = '';
            promoCodeController.clear();
            _promoCodeError = '';
          }

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

      update([
        'cart_items',
        'price_summary',
        'empty_cart',
        'promo_validation',
        'friend_invitations',
      ]);
    } catch (e) {
      hasError = true;
      errorMessage = 'Error loading cart: $e';
      isLoading = false;
      update(['cart_items', 'price_summary', 'empty_cart']);
      debugPrint('❌ Error fetching cart: $e');
    }
  }

  Future<void> fetchCartData() => _fetchCartData();

  Map<String, dynamic> _convertCartItemToMap(CartItem item) {
    return {
      'id': item.id,
      'foodId': item.foodId,
      'foodName': item.foodName,
      'foodImage': item.foodImage,
      'quantity': item.quantity ?? 1,
      'basePrice': item.effectivePrice ?? item.basePrice ?? 0,
      'customizations':
          item.customizations
              ?.map(
                (c) => {
                  'customizationId': c.customizationId,
                  'name': c.name,
                  'price': c.price,
                  'quantity': c.quantity,
                },
              )
              .toList() ??
          [],
      'addOns':
          item.addOns
              ?.map(
                (a) => {
                  'addOnId': a.addOnId,
                  'name': a.name,
                  'price': a.price,
                  'quantity': a.quantity,
                },
              )
              .toList() ??
          [],
      'itemTotal': item.itemTotal ?? 0,
    };
  }

  int _detectScenario(CartItem item) {
    final hasCustomizations =
        item.customizations != null && item.customizations!.isNotEmpty;
    final hasAddOns = item.addOns != null && item.addOns!.isNotEmpty;

    if (!hasCustomizations && !hasAddOns)
      return 1;
    else if (!hasCustomizations && hasAddOns)
      return 2;
    else if (hasCustomizations && !hasAddOns)
      return 3;
    else
      return 4;
  }

  Future<void> updateItemQuantity(
    String foodId,
    int newQuantity, {
    String? customizationId,
    String? addOnId,
  }) async {
    _cartService.localMutationInFlight = true;
    try {
      final itemIndex = cartItems.indexWhere((item) => item.foodId == foodId);
      if (itemIndex == -1) return;

      final item = cartItems[itemIndex];
      final scenario = _detectScenario(item);

      final requestBody = _buildUpdateRequestBody(
        foodId,
        item,
        scenario,
        newQuantity,
        customizationId,
        addOnId,
      );

      if (requestBody == null) return;

      final response = await _apiClient.post(
        endpoint: Urls.addOrUpdateCartUrl,
        data: requestBody,
      );

      debugPrint('Update Cart Response: $response');

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          final updatedModel = CartModel.fromJson(response);

          if (updatedModel.data != null) {
            cartModel = CartModel(
              success: updatedModel.success,
              message: updatedModel.message,
              data: CartData(
                id: updatedModel.data!.id,
                cartCode: updatedModel.data!.cartCode,
                user: updatedModel.data!.user,
                serviceType: updatedModel.data!.serviceType,
                isPrebookCart: updatedModel.data!.isPrebookCart,
                vendor: updatedModel.data!.vendor ?? cartModel?.data?.vendor,
                items: updatedModel.data!.items,
                couponCode:
                    updatedModel.data!.couponCode ??
                    cartModel?.data?.couponCode,
                totals: updatedModel.data!.totals,
                lastUpdatedAt: updatedModel.data!.lastUpdatedAt,
                isCartOwner:
                    updatedModel.data!.isCartOwner ??
                    cartModel?.data?.isCartOwner, // ← add
                friendInvitations:
                    updatedModel.data!.friendInvitations ??
                    cartModel?.data?.friendInvitations, // ← add
              ),
            );
          }

          _cartService.updateCartFromApi({
            'items':
                cartModel!.data!.items
                    ?.map((item) => _convertCartItemToMap(item))
                    .toList() ??
                [],
            'totals': {
              'itemCount': cartModel!.data!.totals?.itemCount ?? 0,
              'grandTotal': cartModel!.data!.totals?.grandTotal ?? 0,
              'subTotal': cartModel!.data!.totals?.subTotal ?? 0,
              'taxAmount': cartModel!.data!.totals?.taxAmount ?? 0,
              'taxPercentage': cartModel!.data!.totals?.taxPercentage ?? 0,
              'packingChargeTotal':
                  cartModel!.data!.totals?.packingChargeTotal ?? 0,
              'discountTotal': cartModel!.data!.totals?.discountTotal ?? 0,
              'couponDiscount': cartModel!.data!.totals?.couponDiscount ?? 0,
            },
          });

          update(['cart_items', 'price_summary', 'empty_cart']);
        } else {
          Get.snackbar('Error', response['message'] ?? 'Failed to update cart');
        }
      }
    } catch (e) {
      debugPrint('Exception while updating item: $e');
      Get.snackbar('Error', 'Failed to update cart');
    } finally {
      _cartService.localMutationInFlight = false;
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
      return {
        'foodId': foodId,
        'quantity': newQuantity,
        'serviceType': serviceType,
      };
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
          'updateAddOns': true,
        };
      }
    } else if (scenario == 3) {
      if (customizationId != null) {
        return {
          'foodId': foodId,
          'quantity': 1,
          'serviceType': serviceType,
          'customizations': _buildUpdatedCustomizationsArray(
            item,
            customizationId,
            newQuantity,
          ),
        };
      }
    } else if (scenario == 4) {
      if (customizationId != null) {
        return {
          'foodId': foodId,
          'quantity': 1,
          'serviceType': serviceType,
          'customizations': _buildUpdatedCustomizationsArray(
            item,
            customizationId,
            newQuantity,
          ),
          'addOns': _buildAddOnsArray(item),
        };
      } else if (addOnId != null) {
        return {
          'foodId': foodId,
          'quantity': 1,
          'serviceType': serviceType,
          'customizations': _buildCustomizationsArray(item),
          'addOns': _buildUpdatedAddOnsArray(item, addOnId, newQuantity),
          'updateAddOns': true,
        };
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _buildAddOnsArray(CartItem item) {
    if (item.addOns == null || item.addOns!.isEmpty) return [];
    return item.addOns!
        .map(
          (addOn) => {
            'addOnId': addOn.addOnId,
            'quantity': addOn.quantity ?? 0,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> _buildUpdatedAddOnsArray(
    CartItem item,
    String addOnId,
    int newQuantity,
  ) {
    if (item.addOns == null || item.addOns!.isEmpty) return [];
    return item.addOns!.map((addOn) {
      return {
        'addOnId': addOn.addOnId,
        'quantity':
            addOn.addOnId == addOnId ? newQuantity : (addOn.quantity ?? 0),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildCustomizationsArray(CartItem item) {
    if (item.customizations == null || item.customizations!.isEmpty) return [];
    return item.customizations!
        .map(
          (custom) => {
            'customizationId': custom.customizationId,
            'quantity': custom.quantity ?? 0,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> _buildUpdatedCustomizationsArray(
    CartItem item,
    String customizationId,
    int newQuantity,
  ) {
    if (item.customizations == null || item.customizations!.isEmpty) return [];
    return item.customizations!.map((custom) {
      return {
        'customizationId': custom.customizationId,
        'quantity':
            custom.customizationId == customizationId
                ? newQuantity
                : (custom.quantity ?? 0),
      };
    }).toList();
  }

  void removeItem(String itemId) {
    final items =
        _cartService.cartItems
            .where((item) => item['foodId'] != itemId)
            .toList();
    _cartService.cartItems.value = items;
    update(['cart_items', 'price_summary', 'empty_cart']);
  }

  // ─── Price getters ────────────────────────────────────────────────────────
  double get subtotal => cartModel?.data?.totals?.subTotal ?? 0;
  double get deliveryFee => 0.0;
  double get taxAmount => cartModel?.data?.totals?.taxAmount ?? 0;
  double get taxPercentageValue =>
      cartModel?.data?.totals?.taxPercentage ?? 0;
  double get packingCharge =>
      (cartModel?.data?.totals?.packingChargeTotal ?? 0).toDouble();
  double get discountAmount =>
      (cartModel?.data?.totals?.discountTotal ?? 0).toDouble();
  double get couponDiscount =>
      (cartModel?.data?.totals?.couponDiscount ?? 0).toDouble();
  double get totalAmount => _cartService.totalPrice.value;
  int get itemCount => _cartService.itemCount.value;

  // ─── Instructions ─────────────────────────────────────────────────────────
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

  // ─── Promo / Coupon ───────────────────────────────────────────────────────
  void setAppliedPromoCode(String code) {
    _appliedPromoCode = code;
    promoCodeController.text = code;
    _promoCodeError = '';
    isPromoApplying = false;
    update(['promo_validation', 'price_summary']);
  }

  void setPromoError(String error) {
    _promoCodeError = error;
    isPromoApplying = false;
    update(['promo_validation']);
  }

  void removePromoCode() {
    _appliedPromoCode = '';
    _promoCodeError = '';
    isPromoApplying = false;
    promoCodeController.clear();
    update(['promo_validation', 'price_summary']);
  }

  Future<void> removeCouponFromCart({Function(String error)? onError}) async {
    _cartService.localMutationInFlight = true;
    try {
      final vendorId = cartModel?.data?.vendor?.id ?? '';
      final response = await _apiClient.delete(
        endpoint:
            vendorId.isNotEmpty
                ? '${Urls.removeCouponUrl}?vendor=$vendorId'
                : Urls.removeCouponUrl,
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true) {
          await _fetchCartData();
          debugPrint('✅ Coupon removed');
        } else {
          onError?.call(response['message'] ?? 'Failed to remove coupon');
        }
      } else {
        onError?.call('Failed to remove coupon');
      }
    } catch (e) {
      debugPrint('❌ Error removing coupon: $e');
      final message = e.toString().replaceAll('Exception: ', '');
      onError?.call(message);
    } finally {
      _cartService.localMutationInFlight = false;
    }
  }

  // ─── Clear Cart ───────────────────────────────────────────────────────────
  Future<bool> clearCartApi({Function(String error)? onError}) async {
    _cartService.localMutationInFlight = true;
    try {
      final response = await _apiClient.delete(endpoint: Urls.clearCartUrl);

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true) {
          cartModel = null;
          _appliedPromoCode = '';
          _promoCodeError = '';
          promoCodeController.clear();
          _cartService.clearCart();
          update([
            'cart_items',
            'price_summary',
            'empty_cart',
            'promo_validation',
          ]);
          debugPrint('✅ Cart cleared via API');
          return true;
        } else {
          final msg = response['message'] ?? 'Failed to clear cart';
          onError?.call(msg);
          debugPrint('❌ Clear cart API returned failure: $msg');
        }
      } else {
        onError?.call('Failed to clear cart');
      }
    } catch (e) {
      debugPrint('❌ Error clearing cart: $e');
      final message = e.toString().replaceAll('Exception: ', '');
      onError?.call(message);
    } finally {
      _cartService.localMutationInFlight = false;
    }
    return false;
  }

  void formatPromoCode(String value) {
    final upperCaseValue = value.toUpperCase();
    if (promoCodeController.text != upperCaseValue) {
      promoCodeController.value = promoCodeController.value.copyWith(
        text: upperCaseValue,
        selection: TextSelection.collapsed(offset: upperCaseValue.length),
      );
    }
    update(['promo_validation']);
  }

  void clearPromoError() {
    if (_promoCodeError.isNotEmpty) {
      _promoCodeError = '';
      update(['promo_validation']);
    }
  }

  // ─── Send Invite ──────────────────────────────────────────────────────────
  Future<bool> sendInvite({required String phone}) async {
    try {
      debugPrint('📨 Sending invite to +91$phone...');

      final response = await _apiClient.post(
        endpoint: Urls.sendInivtesUrl,
        data: {'phone': phone, 'dialCode': '+91'},
      );

      if (response == null) {
        Get.snackbar(
          'Error',
          'Failed to send invitation. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final success = response['success'] == true;
      final message = (response['message'] ?? '').toString();

      if (success) {
        debugPrint('✅ Invite sent — re-fetching cart for updated invitations');
        await _fetchCartData();
        return true;
      } else {
        Get.snackbar(
          'Error',
          message.isNotEmpty ? message : 'Failed to send invitation.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending invite: $e');
      final message = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        message.isNotEmpty ? message : 'Failed to send invitation.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ─── Remove Invite ────────────────────────────────────────────────────────
  Future<void> removeInvite(String inviteId) async {
    if (inviteId.isEmpty) return;
    try {
      debugPrint('🗑️ Removing invite: $inviteId');

      final endpoint = Urls.removeInviteUrl.replaceAll('{inviteId}', inviteId);
      final response = await _apiClient.delete(endpoint: endpoint);

      if (response != null &&
          response is Map<String, dynamic> &&
          response['success'] == true) {
        debugPrint('✅ Invite removed — re-fetching cart');
        await _fetchCartData();
      } else {
        final msg =
            (response is Map ? response['message'] : null) ??
            'Failed to remove invite';
        Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('❌ Error removing invite: $e');
      final message = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        message.isNotEmpty ? message : 'Failed to remove invite.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─── Friend invitation getters ────────────────────────────────────────────
  bool get isCartOwner => cartModel?.data?.isCartOwner ?? true;
  List<FriendInvitation> get friendInvitations =>
      cartModel?.data?.friendInvitations ?? [];

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _getCleanServiceType(String servicePreference) {
    return ServiceType.normalize(servicePreference);
  }

  void placeOrder() {
    if (!validateInstructions()) return;

    if (cartItems.isEmpty) {
      Get.snackbar(
        'Empty Cart',
        'Please add items to cart before placing order',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(Routes.orderConfirmationView);
  }

  void retryFetchCart() => _fetchCartData();

  @override
  void onClose() {
    _quantityDebounceTimer?.cancel();
    instructionsController.dispose();
    promoCodeController.dispose();
    super.onClose();
  }
}
